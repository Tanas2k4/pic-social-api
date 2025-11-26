namespace PicSocial.Server.DTOs.AuthDto
{
    public class LoginDto
    {
        public string Email { get; set; } = null!;
        public string Password { get; set; } = null!;
    }
}