import FirebaseAuth

class CreateTodayTag {
    func call() {
        guard Auth.auth().currentUser != nil else { return }

        User(id: Auth.auth().currentUser?.uid ?? "NotFound")
            .collection(path: .tags)
            .whereField("kind", isEqualTo: "today")
            .getDocuments(completion: { snapshot, err in
                if err == nil && snapshot!.isEmpty {
                    _ = Tag.create(name: "Today", kind: "today")
                }
            })
    }
}
