using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using PicSocial.Server.Data;
using PicSocial.Server.Models;
using PicSocial.Server.Services;
using PicSocial.Server.Services.Implementations;
using PicSocial.Server.Services.Interfaces;
using System.Text;

var builder = WebApplication.CreateBuilder(args);
//Add AddDbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
//Add Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();
// JWT config
var jwtSettings = builder.Configuration.GetSection("Jwt");
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]))
    };
});
// Add services to the container
builder.Services.AddControllers();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IFollowService, FollowService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IProfileService, ProfileService>();
builder.Services.AddScoped<IReactionService, ReactionService>();
builder.Services.AddScoped<IShareService, ShareService>();
builder.Services.AddScoped<ICommentService, CommentService>();
builder.Services.AddScoped<ICoverPhotoService, CoverPhotoService>();
builder.Services.AddScoped<IAvatarService, AvatarService>();
builder.Services.AddScoped<IPostService, PostService>();
builder.Services.AddScoped<ILicenseService, LicenseService>();
builder.Services.AddScoped<IPhotoService, PhotoService>();
// Add Google Cloud Storage service
builder.Services.AddSingleton<GoogleCloudStorageService>();
// Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "PicSocial API",
        Version = "v1"
    });
});
// CORS: cho phép FE gọi API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowClient",
        policy => policy
            .WithOrigins("http://localhost:5173") // FE dev port
            .AllowAnyHeader()
            .AllowAnyMethod());
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection(); // Tắt HTTPS để tạm thời chặn cổng https

// Áp dụng CORS
app.UseCors("AllowClient");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Seed default data (roles, admin user)
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
    var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
    await SeedData.InitializeAsync(userManager, roleManager);
}
// run app
app.Run();
