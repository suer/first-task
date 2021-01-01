import Ballcap
import FirebaseAuth

class AddTodayTag {
    func call() {
        let today = Date()

        let user = User(id: Auth.auth().currentUser?.uid ?? "NotFound")

        user
            .collection(path: .tags)
            .whereField("kind", isEqualTo: "today")
            .getDocuments(completion: { snapshot, err in
                guard err == nil else { return }
                guard !snapshot!.isEmpty else { return }

                let todayTag = try? Tag(snapshot: snapshot!.documents[0])
                if let todayTag = todayTag {
                    user
                        .collection(path: .tasks)
                        .whereField("startDate", isGreaterThanOrEqualTo: today.startOfDay)
                        .whereField("startDate", isLessThanOrEqualTo: today.endOfDay)
                        .getDocuments(completion: { snapshot, err in
                            guard err == nil else { return }

                            let batch = Batch()
                            for s in snapshot!.documents {
                                let task = try? Task(snapshot: s)
                                if let task = task {
                                    if !task[\.tagIds].contains(todayTag.id) {
                                        task[\.tagIds] = .arrayUnion([todayTag.id])
                                    }
                                    batch.update(task)
                                }
                            }
                            batch.commit()
                        })
                }
            })
    }
}
