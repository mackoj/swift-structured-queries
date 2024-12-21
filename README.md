# Swift Structured Queries

  - [ ] How low can we make the supported platforms?

  - [ ] Add support for custom binding logic per property:

    ```swift
    @Column(.format(.iso8601))
    var date: Date

    @Column(.format(.timeIntervalSince1970))
    var date: Date
    ```

  - [ ] Add support for draft types where primary key exists:
  
    ```diff
     @Table
     struct SyncUp {
    +  @Column(.primaryKey(.autoincrement))
       var id: Int
    +  @Column
       var title = ""
    +  struct Draft {
    +    var title = ""
    +  }
     }
    ```
    
      - [ ] Add support for inserting draft types:
      
        ```swift
        let draft = SyncUp.Draft(title: "Engineering")
        SyncUp.insert(draft)
        ```

  - [ ] Dirty tracking for minimal updates?
  
    ```diff
     @Table
     struct SyncUp {
       var title: String
    +  {
    +    get { _title }
    +    set { 
    +      _$updateTracker.track(\.title)
    +      _title = newValue
    +    }
    +  }
    +  private var _title: String
    +  private let _$updateTracker = UpdateTracker()
     }
    ```

      - [ ] Would require an `updatedAt` or some kind of `revisionNumber` to trigger a conflict on
            data races.
