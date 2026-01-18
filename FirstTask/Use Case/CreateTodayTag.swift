import FirebaseAuth

class CreateTodayTag {
    func call() {
        guard let userId = Auth.safeAuth()?.currentUser?.uid else { return }

        User(id: userId ?? "NotFound")
            .collection(path: .tags)
            .whereField("kind", isEqualTo: "today")
            .getDocuments(completion: { snapshot, err in
                if err == nil && snapshot!.isEmpty {
                    _ = Tag.create(name: "Today", kind: "today")
                }
            })
    }
}
