using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using PicSocial.Server.DTOs.AuthDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PicSocial.Server.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;
        public AuthService(UserManager<ApplicationUser> userManager, IConfiguration configuration)
        {
            _userManager = userManager;
            _configuration = configuration;
        }

        // Register a new user
        public async Task<Result> RegisterAsync(RegisterDto registerDto)
        {
            //check password confirm 
            if (registerDto.Password != registerDto.ConfirmPassword)
                return Result.Bad("Password and Confirm Password do not match.");

            var user = new ApplicationUser
            {
                Email = registerDto.Email,
                UserName = registerDto.UserName,
                FullName = registerDto.FirstName,
            };

            var result = await _userManager.CreateAsync(user, registerDto.Password);
            if (!result.Succeeded)
                return Result.Bad(string.Join(", ", result.Errors.Select(e => e.Description)));

            return Result.Ok("User registered successfully !!");
        }

        // Login user
        public async Task<Results<string>> LoginAsync(LoginDto dto)
        {
            var user = await _userManager.FindByEmailAsync(dto.Email);

            if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
                return Results<string>.Unauthorized("Invalid Email or Password.");

            var token = await GenerateTokenAsync(user);

            //gán avatar mặc định 
            // if (string.IsNullOrEmpty(user.AvatarUrl))
            // {    
            //     user.AvatarUrl = "avatar-default-link";
            //     await _userManager.UpdateAsync(user);
            // }
            return Results<string>.Ok(token, "Login successful.");
        }

        //generate JWT token for login
        public async Task<string> GenerateTokenAsync(ApplicationUser user)
        {
            var jwtSettings = _configuration.GetSection("Jwt");

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? ""),
                new Claim("username", user.UserName ?? "")
            };

            //Lấy roles của user bất đồng bộ
            var roles = await _userManager.GetRolesAsync(user);
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var expireMinutesStr = jwtSettings["ExpireMinutes"] ?? jwtSettings["ExpiryInMinutes"];
            var expireMinutes = double.TryParse(expireMinutesStr, out var m) ? m : 120.0;

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expireMinutes),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
