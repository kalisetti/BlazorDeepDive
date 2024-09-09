--
-- 2024/08/16
-- Blazor Deep Dive
--
--


-------------------------------------------------------------------------------------------
--
-- Section 1: Introduction
--
--


* SSR - Static Serverside Rendering(base)

	- Two types of interactivity:

		1. Server Interactivity
		2. WebAssembly Interactivity


* Signal R Channel/Websocket
	- It is like a peer-to-peer communication between client and server

The source code in this course is on Github:

https://github.com/frank-liu-toronto/BlazorDeepDive

-------------------------------------------------------------------------------------------
--
-- Section 2: Blazor SSR
--
--


--
-- 5. Two Types of Components
--

1. Routable Components (Sometimes it is also called page components)
	- Just add @page "/servers" at the top of the component

2. Non-routable Components (Sometimes called as re-usable components)


Examples:

1. Create `/Components/Controls/ServerComponent.razor`

<p>
	Server is online!
</p>

@code {

}

2. Create `/Components/Pages/Servers.razor`
@page "/servers"

@using ServerManagement.Components.Controls

<h3>Servers</h3>
<br/>
<br/>

<ServerComponent></ServerComponent>

@code {

}


# WE CAN MOVE THE "@using ServerManagement.Components.Controls" DIRECTIVE TO "_Imports.razor"
 
 

--
-- 6. Razor Syntax Implicit Razor Expression
--

* Implicit razor expression, nothing but referring the C# variable in HTML with @ symbol

<p>
	@server.Name is in @server.City
</p>

@code {
	private Server server = new Server { Name = "Server 1", City = "Perth" };
}



--
-- 7. Razor Syntax Explicit Razor Expression
--

* Use the round braces, and you can write code in it

<div style="color: @(server.IsOnline ? "green" : "red")">
	@server.Name is in @server.City that is @(server.IsOnline ? "online" : "offline")
</div>

@code {
	private Server server = new Server { Name = "Server 1", City = "Perth" };
}


--
-- 13. Working with Static Resources
--

* In the Program.cs the following line(middleware) is responsible for mapping requests to blazor

app.MapRazorComponents<App>();

* And `app.UseStaticFiles();` is responsible for mapping static files

* Basically all our static resources goes under `wwwroot` folder

--
-- 15. Route parameters & route constraints
--

Simply change the page directive and define the property. Here the property should match the url
parameter name and it is case insensitive.
 
/Components/Pages/EditServer.razor 
 
from 

@page "/servers/edit"

<h3>EditServer</h3>

@code {
}

to


@page "/servers/{id}"

<h3>EditServer</h3>

@code {
	[Parameter]
	public string? Id { get; set; }
}


* We use root constraints to specify the data type of the parameter id for the url

/Components/Page/EditServer.razor

@page "/servers/{id:int}"

<h3>EditServer</h3>

@Id

@code {
	[Parameter]
	public int? Id { get; set; }
}


*** How to make a url parameter optional?

	You can simply put a question mark. 
	
	@page "/servers/edit/{id:int?}"
	

--
-- 16. Use OnParametersSet to receive parameter value
--

* OnParametersSet is one of the lifecycle event that is triggered after the parameters passed to a url 
	are set to the component parameters. 
	
* Similarly we can also use `OnParametersSetAsync` method for doing Aynsc operations in the method

Example:-

/Components/Page/EditServer.razor

@page "/servers/{id:int?}"

<h3>EditServer</h3>

@if (server != null) {
	<p>
		@server.Name
	</p>
	<p>
		@server.City
	</p>
	<p>
		@server.IsOnline
	</p>
}

<br />
<a href="/servers" class="btn btn-link">Close</a>

@code {
	[Parameter]
	public int? Id { get; set; }

	private Server? server;

	protected override void OnParametersSet() {
		server = ServersRepository.GetServerById(this.Id);
	}
}

--
-- 17. Use Form and Input components to display and collect data
--

* Microsoft has some built in components
* We can use the built-in EditForm component for HTML forms
* Here when we say Model="server", it is like we are saying hey this form is going to 
	work with this data, it basically represents the data context for the form.
	

-- /Components/Page/EditServer.razor
@page "/servers/{id:int?}"

<h3>EditServer</h3>

@if (server != null) {
	<EditForm Model="server">
		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">Name</label>
			</div>
			<div class="col-6">
				<InputText @bind-Value="server.Name" class="form-control"></InputText>
			</div>
		</div>

		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">City</label>
			</div>
			<div class="col-6">
				<InputText @bind-Value="server.City" class="form-control"></InputText>
			</div>
		</div>

		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">Online</label>
			</div>
			<div class="col-6">
				<InputCheckbox @bind-Value="server.IsOnline" class="form-check-input"></InputCheckbox>
			</div>
		</div>
	</EditForm>
}



--
-- 18. Form submission and model binding
--

* Blazor SSR requires every edit form to have a form name in order to distinguish one form 
from the other form, one event handler from the other event handler.

* And we define an event handler for the form to submit the data 

1. We need to convert our local variable "server" into a property, thats a requirement.
2. And then specify an attribute called [SupplyParameterFromForm], this way the server
	can recive the form data.
3. If we have multiple forms, we need to specify it as a parameter like, we dont need to specify
	if the page has only one form.
	
	- [SupplyParameterFromForm(FormName = "formServer")]
 
-- Example
/Components/Pages/EditServer.razor

@code {
	[Parameter]
	public int? Id { get; set; }

	[SupplyParameterFromForm(FormName ="formServer")]
	private Server? server { get; set; }

	protected override void OnParametersSet() {
		server = ServersRepository.GetServerById(this.Id);
	}

	private void Submit() {
		
	}
}


* But when I put breakpoint on the closing bracket of Submit() button and run the application,
	in the debug mode, when I quick watch the server variable, it is not getting the updated
	value from the form.
	
	- The thing is we actually get the form data in "server", however it is overridden by
		OnParametersSet function. We can simply fix it by adding a condition to see if the
		variable is empty then only populate it with the static data.
		
		We can use the following shortcut to set the value only if server is null:
		
		server ??= ServersRepository.GetServerById(this.Id);

* Note that, since we didnt add an input element to hold serverId value for the selected
	record, when we submit it submits the serverID as 0. So, we better add a hidden input 
	element to populate it.
	
-- Code after the changes
/Components/Pages/EditServer.razor
@page "/servers/{id:int?}"

<h3>EditServer</h3>

@if (server != null) {
	<EditForm Model="server" FormName="formServer" OnSubmit="Submit">
		<InputNumber @bind-Value="server.ServerId" hidden></InputNumber>
		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">Name</label>
			</div>
			<div class="col-6">
				<InputText @bind-Value="server.Name" class="form-control"></InputText>
			</div>
		</div>

		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">City</label>
			</div>
			<div class="col-6">
				<InputText @bind-Value="server.City" class="form-control"></InputText>
			</div>
		</div>

		<div class="row mb-3">
			<div class="col-2">
				<label class="col-form-label">Online</label>
			</div>
			<div class="col-6">
				<InputCheckbox @bind-Value="server.IsOnline" class="form-check-input"></InputCheckbox>
			</div>
		</div>
		<br/>
		<button class="btn btn-primary" type="submit">Update</button>
		&nbsp;
		<a href="/servers" class="btn btn-primary">Close</a>
	</EditForm>
}



@code {
	[Parameter]
	public int? Id { get; set; }

	[SupplyParameterFromForm(FormName ="formServer")]
	private Server? server { get; set; }

	protected override void OnParametersSet() {
		server ??= ServersRepository.GetServerById(this.Id);
	}

	private void Submit() {
		if (server != null) {
			ServersRepository.UpdateServer(server.ServerId, server);
		}
	}
}


--
-- 19. Form Validations
--	

* To make our fields mandatory, we can make use of C# data annotations.
* We just need to add data annodations for the fields in our models.

-- So our model now becomes as shown below with [Required]
-- /Models.Server.cs

using System.ComponentModel.DataAnnotations;

namespace ServerManagement.Models {
	public class Server {
		public Server() { 
			Random random = new Random();
			int randomNumber = random.Next(0, 2);
			IsOnline = randomNumber == 0? false : true;
		}
		public int ServerId { get; set; }
		public bool IsOnline { get; set; }

		[Required]
		public string? Name { get; set; }

		[Required]
		public string? City { get; set; }
	}
}


* And in order to make the edit form validate the model object here or the data context,
	we need to use a couple of components. 
1. Just add the '<DataAnnotationsValidator></DataAnnotationsValidator>' in our form at the top,
	this tells the edit form to actually try to validate the model object based on the
	data annotations.

2. And then we need to specify how we want to spit out the error message.
	One of the easiest ways to do this is by using the 
	'<ValidationSummary></ValidationSummary>' at the top of our form(or maybe below
	the above line). And then the summary will appear on the top.
	
3. And then instead of using "OnSubmit" we use "OnValidSubmit".

* With this, all the validation errors will be listed in the top of the form.
	Eg:
		* The Name field is required.
		* The City field is required.
		
* We can also make the respective validation message right beside the input element
	by using the <ValidationMessage> component.
	

-- So, the form looks like below
-- /Components/Pages/EditServer.razor
<EditForm Model="server" FormName="formServer" OnValidSubmit="Submit">
	<DataAnnotationsValidator></DataAnnotationsValidator>
	<ValidationSummary></ValidationSummary>
	<InputNumber @bind-Value="server.ServerId" hidden></InputNumber>
	<div class="row mb-3">
		<div class="col-2">
			<label class="col-form-label">Name</label>
		</div>
		<div class="col-6">
			<InputText @bind-Value="server.Name" class="form-control"></InputText>
		</div>
		<div class="col">
			<ValidationMessage For="() => server.Name"></ValidationMessage>
		</div>
	</div>

	<div class="row mb-3">
		<div class="col-2">
			<label class="col-form-label">City</label>
		</div>
		<div class="col-6">
			<InputText @bind-Value="server.City" class="form-control"></InputText>
		</div>
		<div class="col">
			<ValidationMessage For="() => server.City"></ValidationMessage>
		</div>
	</div>

	<div class="row mb-3">
		<div class="col-2">
			<label class="col-form-label">Online</label>
		</div>
		<div class="col-6">
			<InputCheckbox @bind-Value="server.IsOnline" class="form-check-input"></InputCheckbox>
		</div>
	</div>
	<br/>
	<button class="btn btn-primary" type="submit">Update</button>
	&nbsp;
	<a href="/servers" class="btn btn-primary">Close</a>
</EditForm>


--
-- 20. Navigation with NavigationManager & Dependency Injection
--

* We can navigate to pages from within C# using NavigationManager.
	We just need to inject and use.

	@inject NavigationManager NavigationManager
	
	private void Submit() {
		if (server != null) {
			ServersRepository.UpdateServer(server.ServerId, server);
		}

		NavigationManager.NavigateTo("/servers");
	}

* So, what does this inject do? Usually if we want to use a class inside another class,
	we usually instantiate it. So we inject when we dont want to have a dependecy. 
	

--
-- 23. Use EditForm to delete data
--


--
-- 24. Stream Rendering
--


-------------------------------------------------------------------------------------------
--
-- Section 3: Add Server Interactivity
--
--

--
-- 25. What is Interactivity
--

* Traditionally the web pages are reloaded with every request to a new page, so loading
	portion of the page without reloading the entire page is called interactivity.
	
* Interactivity here doesnt mean the interaction between the user and the browser,
	instead it is the interaction between browser and server.


--
-- 26. Use Enhanced Navigation in Blazor SSR for interactivity
--

* By default Blazor apps are enabled with interactivity, this is done through the following 
	js file added by default in App.razor
	
	<script src="_framework/blazor.web.js"></script>
	
* If you remove the above script reference, you can notice that all pages are loading
	in the browser when visited, that means they work almost like a static website
	where every page request ends up in loading in the browser.
	
* You can see how this interactivity works by simply going to developer tools, and monitor
	the html body part being replaced with every request. And also, you can notice in 
	network request log, the request type is shown as fetch(method calling server) instead
	of Document which is for entire page loading.


--
-- 27. Use enhanced form handling in Blazor SSR for interactivity
--

* When we submit our html forms, the blazor app is reloading the page. So to make it use
	partial loading/rendering, we could simply add `Enhance="true"` parameter to our
	forms.
	
	<EditForm Enhance="true" Model="server" FormName="@($"form-server-{server.ServerId}")" OnValidSubmit="@(() => { DeleteServer(server.ServerId); })">
		<button type="submit" class="btn btn-primary">Delete</button>
	</EditForm>

* So basically when we post an html, it submits to server, whereas in this case the
	html post request is intercepted by blazor.web.js which calls the fetch api
	and updates the DOM.


-- Example: /Components/Controls/ServerComponent.razor
@if (server != null) {
	<EditForm Enhanced="true" Model="server" FormName="serverComponentForm" OnSubmit="ChangeServerStatus">
		<InputNumber @bind-Value="server.ServerId" hidden></InputNumber>
		<InputText @bind-Value="server.Name" hidden></InputText>
		<InputText @bind-Value="server.City" hidden></InputText>
		<InputCheckbox @bind-Value="server.IsOnline" hidden></InputCheckbox>

		<div data-name="@server.Name" 
			data-status="Server is @(server.IsOnline ? "online" : "offline")"
			style="color: @(server.IsOnline ? "green" : "red")">
			@server.Name is in @server.City that is @(server.IsOnline ? "online" : "offline")
			&nbsp;
			<button type="submit" class="btn btn-primary">Turn On/Off</button>
		</div>
	</EditForm>
}

@code {
	[SupplyParameterFromForm]
	private Server? server { get; set; }

	protected override void OnParametersSet() {
		// base.OnParametersSet();
		server ??= new Server { Name = "Server 1", City = "Perth" };
	}

	private void ChangeServerStatus() {
		if (server != null) {
			server.IsOnline = !server.IsOnline;
		}
	}
}




--
-- 28. What is Server Interactivity?
--

* From our previous examples we noticed that our blazor.web.js makes the fetch API 
	requests to server and patch the differences in DOM. So this is a request and
	response model. Whenever we request a page or interact, the request goes to the
	server and server processes the request and loads the objects into internal memory and
	send it back in a response and dispose the objects in the local memory.
	
* Actual server interactivity also rely on blazor.web.js, but this time the request and
	response is difference.
	
	So instead of using blazor.web.js to send fetch api requests to the web server,
	Server interactivity uses blazor.web.js file to Setup a websocket channel. And
	that is called a signalR channel. When the user interacts with the DOM, the
	respective updates are sent back to the server via these channel.

	In this case, the DOM tree copy is maintained in server and everytime there are
	changes to the DOM elements, the server processes the requests and generates a new copy
	of the tree. And the server compares the previous image of the tree that is being held
	in the memory with the one generated fresh and send only the changes to the 
	blazor.web.js. And blazor.web.js patches the DOM with these updates.


--
-- 29. Enable Server Interactivity how to make a component interactive
--

* We can remove the earlier `Enhanced="true"` formhandling interactivity, and use server
	interactivity.
* And remove even the EditForm, and change the button type from "submit" to "button"
* This will not work right away, we need to enable server interactivity

* Go to Program.cs and change the following lines

	from 
	// Add services to the container.
	builder.Services.AddRazorComponents();

	app.MapRazorComponents<App>();

	to
	// Add services to the container.
	builder.Services.AddRazorComponents().AddInteractiveServerComponents();

	app.MapRazorComponents<App>().AddInteractiveServerRenderMode();

* But it still doesnt work, because we haven''t specified which component/page is to be
	made interactive. We can simply mention the rendermode in the component like this.
	
	<ServerComponent @rendermode="InteractiveServer"></ServerComponent>
	

	
--
-- 30. Interactivity Location
--

Category 1: Page/Component Level
	* Location 1, We can add the interactivity on the component itself
		
		<ServerComponent @rendermode="InteractiveServer"></ServerComponent>
		
	* Location 2, Or at the top of its parent component, when you specify at the page
		level all the components inside the page all use server interactivity.
		
		@rendermode InteractiveServer
		
	* Location 3, Or you set it inside the component

Category 2: Global Level

	* Set it on the root component of the app in 'App.razor'
	
		So the following changes from:
		
		<body>
			<Routes />
			<script src="_framework/blazor.web.js"></script>
		</body>
		
		to:
		
		<body>
			<Routes @rendermode="InteractiveServer"/>
			<script src="_framework/blazor.web.js"></script>
		</body>


MICROSOFT RECOMMENDED WAY IS:
	<ServerComponent @rendermode="InteractiveServer"></ServerComponent>

--
-- 31. Server Interactivity in Visual Studio project template
--

* We can also specify the rendermode when we create our project in visual studio 

	+ When you select "Interactive Server Mode" -> "Server", it will make those two changes
		we have seen earlier in "Program.cs"

--
-- 32. Three main aspects of interactive components
--

* Once you use interactive component, the application becomes stateful application,
	  at least for that component.
	  
* Un-stateful applications are the traditional request and response models where server
	just disposes anything it holds after sending the response back.
	
* So there are 3 aspects of interactive components

	1) View
	2) Event
	3) State


--
-- 33. Event Handling (Passing Data)
--

* We can pass the parameter like this

	<button type="button" class="btn btn-primary" @onclick="@(() => { SelectCity(city) })">@city</button>

	-- /Components/Pages/Servers.razor
	<div class="container-fluid text-center">
		<div class="row">
			@foreach (var city in cities) {
				<div class="col">
					<div class="card" style="width: 15rem;">
						<img src="@($"/images/{city}.jpg")" class="card-img-top" alt="@city" style="max-height: 8rem;">
						<div class="card-body">
							<button type="button" class="btn btn-primary" @onclick="@(() => { SelectCity(city) })">@city</button>
						</div>
					</div>
				</div>
			}
		</div>
	</div>


-- /Components/Pages/Servers.razor
@page "/servers"
@rendermode InteractiveServer

@inject NavigationManager NavigationManager

<h3>Servers</h3>
<br />
<br />



<div class="container-fluid text-center">
	<div class="row">
		@foreach (var city in cities) {
			<div class="col">
				<div class="card" style="width: 15rem;">
					<img src="@($"/images/{city}.jpg")" class="card-img-top" alt="@city" style="max-height: 8rem;">
					<div class="card-body">
						<button type="button" class="btn btn-primary" @onclick="@(() => { SelectCity(city); })">@city</button>
					</div>
				</div>
			</div>
		}
	</div>
</div>

<br />
<a href="/servers/add" class="btn btn-primary">Add Server</a>
<br />

<ServerComponent @rendermode="InteractiveServer"></ServerComponent>

<ul>
	@foreach (var server in servers) {
		<li>
			@server.Name in @server.City is <span style="color: @(server.IsOnline ? "green" : "red")">@(server.IsOnline ? "online" : "offline")</span>
			&nbsp;
			<a href="/servers/@server.ServerId" class="btn btn-link">Edit</a>
			
			&nbsp;
			<EditForm Enhance="true" Model="server" FormName="@($"form-server-{server.ServerId}")" OnValidSubmit="@(() => { DeleteServer(server.ServerId); })">
				<button type="submit" class="btn btn-primary">Delete</button>
			</EditForm>
		</li>
	}

</ul>

@code {
	private List<string> cities = CitiesRepository.GetCities();
	private List<Server> servers = ServersRepository.GetServers();

	private void DeleteServer(int serverId) {
		if (serverId > 0) {
			ServersRepository.DeleteServer(serverId);
			NavigationManager.Refresh();
		}
	}

	private void SelectCity(string cityName) {
		this.servers = ServersRepository.GetServerByCity(cityName);
	}
}


--
-- 34. Assignment 4: Highlight current City
--


--
-- 36. Update. state variables with Onchange event
--

* Onchange when we call a method without any parameters, by default blazor passes some 
	kind of parameters into the function.
	

-- /Components/Pages/Servers.razor
@page "/servers"
@rendermode InteractiveServer

@inject NavigationManager NavigationManager

<h3>Servers</h3>
<br />
<br />



<div class="container-fluid text-center">
	<div class="row">
		@foreach (var city in cities) {
			<div class="col">
				<div class="card @(selectedCity.Equals(city, StringComparison.OrdinalIgnoreCase) ? "border-primary": "")" style="width: 15rem;">
					<img src="@($"/images/{city}.jpg")" class="card-img-top" alt="@city" style="max-height: 8rem;">
					<div class="card-body">
						<button type="button" class="btn btn-primary" @onclick="@(() => { SelectCity(city); })">@city</button>
					</div>
				</div>
			</div>
		}
	</div>
</div>

<div class="input-group mb-3">
	<input type="text" class="form-control" placeholder="Search Servers" @onchange="HandleServerFilterChange" />
	<button class="btn btn-outline-secondary" type="button" id="button-search" @onclick="HandleSearch">Search</button>
</div>

<br />
	<a href="/servers/add" class="btn btn-primary">Add Server</a>
<br />


<ul>
	@foreach (var server in servers) {
		<li>
			@server.Name in @server.City is <span style="color: @(server.IsOnline ? "green" : "red")">@(server.IsOnline ? "online" : "offline")</span>
			&nbsp;
			<a href="/servers/@server.ServerId" class="btn btn-link">Edit</a>
			
			&nbsp;
			<EditForm Enhance="true" Model="server" FormName="@($"form-server-{server.ServerId}")" OnValidSubmit="@(() => { DeleteServer(server.ServerId); })">
				<button type="submit" class="btn btn-primary">Delete</button>
			</EditForm>
		</li>
	}

</ul>

@code {
	private string selectedCity = "Perth";
	private List<string> cities = CitiesRepository.GetCities();
	private List<Server> servers = ServersRepository.GetServerByCity("Perth");
	private string serverFilter = "";

	private void DeleteServer(int serverId) {
		if (serverId > 0) {
			ServersRepository.DeleteServer(serverId);
			NavigationManager.Refresh();
		}
	}

	private void SelectCity(string city) {
		this.selectedCity = city;
		this.servers = ServersRepository.GetServerByCity(this.selectedCity);
	}

	private void HandleServerFilterChange(ChangeEventArgs args) {
		serverFilter = args.Value?.ToString() ?? string.Empty;
	}

	private void HandleSearch() {
		this.servers = ServersRepository.SearchServers(serverFilter);
		this.selectedCity = string.Empty;
	}
}


--
-- 37. Two way data binding
--

* So far we noticed that, we start with making changes to "View" which triggers the "Events",
	and the events update the "State" variables which in turn updates the "View"
	
* With two way binding we link the "View" directly with the "State", so we can change our 
	previous code and get rid of HandleServerFilterChange and the onchange event alltogether.
	Instead we can use two way binding to directly update the value entered into our search
	field into the state variable "serverFilter".
	

-------------------------------------------------------------------------------------------
--
-- Section 4: Course Project(Part 1): To-Do List App Basics
--
--





-------------------------------------------------------------------------------------------
--
-- Section 5: Non-Routable Razor Component Deep-Dive
--
--



-------------------------------------------------------------------------------------------
--
-- Section 6: Course Project (Part 2): Componentize our To-Do List App
--
--




-------------------------------------------------------------------------------------------
--
-- Section 7: Component Lifecycle Deep-Dive
--
--





-------------------------------------------------------------------------------------------
--
-- Section 8: Routing and Navigation Deep-Dive
--
--




-------------------------------------------------------------------------------------------
--
-- Section 9: Course Project (Part 2): State Management Deep-Dive
--
--




-------------------------------------------------------------------------------------------
--
-- Section 10: WebAssembly Interactivity
--
--




-------------------------------------------------------------------------------------------
--
-- Section 11: Data Access for SSR or Server Interactivity
--
--




-------------------------------------------------------------------------------------------
--
-- Section 12: Data Access for Blazor with WebAssembly Interactivity
--
--



-------------------------------------------------------------------------------------------
--
-- Section 13: Authentication and Authorization
--
--




-------------------------------------------------------------------------------------------
--
-- Section 14: Pre-Rendering in Blazor
--
--



-------------------------------------------------------------------------------------------
--
-- Section 15: BONUS SECTION
--
--
