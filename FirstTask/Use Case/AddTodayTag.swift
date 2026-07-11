import Firebase
import FirebaseAuth
import FirebaseFirestore

class AddTodayTag {
    func call() {
        let today = Date()

        guard let userId = Auth.safeAuth()?.currentUser?.uid else { return }
        let user = User(id: userId)
        let tagsCollection = user.collection(path: .tags)
        let tasksCollection = user.collection(path: .tasks)

        tagsCollection
            .whereField("kind", isEqualTo: "today")
            .getDocuments(completion: { snapshot, err in
                guard err == nil else { return }
                guard !snapshot!.isEmpty else { return }

                let todayTag = try? Tag(snapshot: snapshot!.documents[0])
                if let todayTag = todayTag {
                    let todayTagId = todayTag.id
                    tasksCollection
                        .whereField("startDate", isGreaterThanOrEqualTo: today.startOfDay)
                        .whereField("startDate", isLessThanOrEqualTo: today.endOfDay)
                        .getDocuments(completion: { snapshot, err in
                            guard err == nil else { return }

                            let batch = Firestore.firestore().batch()
                            for s in snapshot!.documents {
                                let task = try? Task(snapshot: s)
                                if let task = task {
                                    if !task.tagIds.contains(todayTagId) {
                                        task.tagIds.append(todayTagId)
                                        do {
                                            try batch.setData(from: task, forDocument: task.documentReference, merge: true)
                                        } catch {
                                            print("Error updating task: \(error)")
                                        }
                                    }
                                }
                            }
                            batch.commit { error in
                                if let error = error {
                                    print("Error committing batch: \(error)")
                                }
                            }
                        })
                }
            })
    }
}
