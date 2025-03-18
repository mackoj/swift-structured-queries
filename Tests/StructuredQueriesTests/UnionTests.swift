/*
 TODO: implement union

 Reminder.where { $0.isCompleted }
   .union(Reminder.where { !$0.isCompleted })
   .union(Reminder.all())

 Reminder.select(\.title)
   .union(RemindersList.select(\.name))
   .union(Tag.select(\.name))

 Statement<Reminder>
 */
