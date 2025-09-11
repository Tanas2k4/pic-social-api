using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;

namespace PicSocial.Server.Data
{
    public static class SeedData
    {
        public static async Task InitializeAsync(
            UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager
        )
        {
            //Create "Admin" roles
            if (!await roleManager.RoleExistsAsync("Admin"))
            {
                await roleManager.CreateAsync(new IdentityRole("Admin"));
            }

            //Create default Admin-User
            var adminEmail = "admin@gmail.com"; // Default Admin-Email
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                adminUser = new ApplicationUser
                {
                    UserName = "Admin",
                    Email = adminEmail,
                    FirstName = " Tran Tan",
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(adminUser, "Admin@123"); // Default Admin-Password
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(adminUser, "Admin");
                }
            }     
        }
    }
}