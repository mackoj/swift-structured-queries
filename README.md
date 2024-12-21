# Swift Structured Queries

  - [ ] Add support for inserting full records:
  
    ```swift
    SyncUp.insert([SyncUp(id: 1, isActive: true, title: "Engineering"])
    ```

  - [ ] Add support for custom binding logic per property:

    ```diff
     @Column(.strategy(.iso8601))
     var date: Date
    +struct Columns: TableExpression {
    +  let date = Column<Meeting, Date>("date", strategy: .iso8601)
    +}

     @Column(.strategy(.timeIntervalSince1970))
     var date: Date
    +struct Columns: TableExpression {
    +  let date = Column<Meeting, Date>("date", strategy: .timeIntervalSince1970)
    +}
    
     typealias Column<T: Table, C: QueryBindable> = BindableColumn<T, C, C>
    ```
    
    Seems like there isn't a way to make this type-safe, though. Just a bad macro compiler error.

  - [ ] Add support for draft types where primary key exists:
  
    ```diff
     @Table
     struct SyncUp {
    +  @Column(.primaryKey(.autoincrement))
       var id: Int
    +  @Column
       var title = ""
     }
    +extension SyncUp: Table {
    +  struct Columns: TableExpression, PrimaryKeyed {
    +    let id = Column<SyncUp, Int>("id", .primaryKey(.autoIncrement))
    +    let title = Column<SyncUp, String>("title")
    +    let allColumns: [any ColumnExpression] = [id, title]
    +    let primaryKey: Column<SyncUp, Int> { id }
    +  }
    +  struct Draft {
    +    var title = ""
    +  }
    +}
    ```
    
      - [ ] Add support for inserting draft types:
      
        ```swift
        let draft = SyncUp.Draft(title: "Engineering")
        SyncUp.insert([draft])
        ```
        
      - [ ] Add other primary key-friendly functionality:
      
        ```swift
        SyncUp.find(id)
        ```
        ```diff
         @BelongsTo(SyncUp.self) var syncUp
        +: some Statement<SyncUp> {
        +  SyncUp.all().where { $0.primaryKey == syncUpID }.first
        +}
        +@Column
        +var syncUpID: SyncUp.ID
        
         @HasMany(Attendee.self, \.syncUpID) var attendees
        +: some Statement<[Attendee]> {
        +  Attendee.all().where { $0.syncUpID == primaryKey }
        +}
        ```
        
        Might not be possible in an ergonomic way. No type inference at this level in macros.

  - [ ] Dirty tracking for minimal updates?

    ```diff
     @Table
     struct SyncUp {
       var title: String
    +  {
    +    get { _title }
    +    set { 
    +      _$updateTracker.withMutation(\.title) {
    +        _title = newValue
    +      }
    +    }
    +  }
    +  private var _title: String
    +  private let _$updateTracker = UpdateTracker()
     }
    ```
    ```swift
    var syncUp: SyncUp
    syncUp.title += " Copy"
    SyncUp.update(syncUp)
    // UPDATE "syncUps" SET "title" = ("syncUps"."title" || ?) WHERE "syncUps"."id" = ?
    ```

      - [ ] Would require an `updatedAt` or some kind of `revisionNumber` to trigger a conflict on
            data races.
