using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using Serilog.Events;

namespace <namespace>
{
    public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
        var appsettings = new Appsettings();
        Configuration.Bind(appsettings);

        services.AddScoped<ApiKeyFilter>();

        services.AddHttpClient();
        services.AddHttpContextAccessor();

        services.AddSingleton(appsettings)
        .AddScoped<IUserInfo, WindowsUserInfo>()
        .AddScoped<IClaimsTransformation, ClaimsTransformation>()
        .AddScoped<IAuthorizationHandler, ApiKeyHandler>()
        .AddSingleton<IUserManager, UserManager>();


        services.AddAuthentication(Microsoft.AspNetCore.Server.IISIntegration.IISDefaults.AuthenticationScheme);
        services.AddAuthorization(options =>
        {
            options.AddPolicy(Policy.LocalWrite, policy =>
                            policy.RequireClaim(Policy.LocalApplicationRoles.ClaimType, Policy.LocalApplicationRoles.WRITE, Policy.LocalApplicationRoles.ADMIN));
            options.AddPolicy(Policy.LocalRead, policy =>
                            policy.RequireClaim(Policy.LocalApplicationRoles.ClaimType, Policy.LocalApplicationRoles.READ, Policy.LocalApplicationRoles.ADMIN));
            options.AddPolicy(Policy.LocalAdmin, policy =>
                            policy.RequireClaim(Policy.LocalApplicationRoles.ClaimType, Policy.LocalApplicationRoles.ADMIN));
            options.AddPolicy(Policy.ApiKey, policy =>
            {
                policy.Requirements.Add(new ApiKeyRequirement());
                policy.RequireClaim(Policy.LocalApplicationRoles.ClaimType, Policy.LocalApplicationRoles.APIKEY_ACESS, Policy.LocalApplicationRoles.ADMIN);
            });
        });

        services.AddCors(options =>
        {
            options.AddDefaultPolicy(
                builder =>
                {
                    builder.WithOrigins("<host>").AllowAnyHeader().AllowAnyMethod();
                });
        });

        services.AddControllers()
            .AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.DictionaryKeyPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
                options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
                    // options.JsonSerializerOptions.IgnoreNullValues = true;
                });
        services.AddSignalR();

        Configurations.InitializeConfigurations(Configuration, services, appsettings);
        //services.AddAuthentication(IISDefaults.AuthenticationScheme);
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        app.UseSerilogRequestLogging(options =>
        {
                // Customize the message template
                options.MessageTemplate = "Handled {RequestPath}";

                // Emit debug-level events instead of the defaults
                options.GetLevel = (httpContext, elapsed, ex) => LogEventLevel.Debug;

                // Attach additional properties to the request completion event
                options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
            {
                diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
                diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
            };
        });

        app.UseHttpsRedirection();

        app.UseRouting();
        app.UseCors();
        app.UseAuthentication();
        app.UseAuthorization();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
            endpoints.MapHub<SystemHub>("/system-hub");
            endpoints.MapHub<UserHub>("/user-hub");
        });
    }
}
}
