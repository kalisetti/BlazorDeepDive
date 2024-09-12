namespace ToDoApp.Models {
	public class ToDoItemsRepository {
		private static List<ToDoItem> items = new List<ToDoItem>() { 
			new ToDoItem { Id = 1, Name = "Task1"},
			new ToDoItem { Id = 2, Name = "Task2"},
			new ToDoItem { Id = 3, Name = "Task3"},
			new ToDoItem { Id = 4, Name = "Task4"},
			new ToDoItem { Id = 5, Name = "Task5"},
		};

		public static List<ToDoItem> GetItems() {
			var sortedItems = items.
				OrderBy(item => item.IsCompleted)
				.ThenByDescending(item => item.Id)
				.ToList();

			return sortedItems;
		}

		public static void AddItem(ToDoItem item) {
			int maxId = items.Max(t => t.Id);
			item.Id = maxId + 1;
			items.Insert(0, item);
		}
	}
}
