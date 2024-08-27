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
