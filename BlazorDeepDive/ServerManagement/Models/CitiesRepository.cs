namespace ServerManagement.Models {
	public class CitiesRepository {
		private static List<string> cities = new List<string>() {
			"Perth",
			"Melbourne",
			"Brisbane",
			"NSW"
		};

		public static List<string> GetCities() => cities;
	}
}
