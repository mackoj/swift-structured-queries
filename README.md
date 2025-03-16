# Swift Structured Queries

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
