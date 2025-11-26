using PicSocial.Server.DTOs.AuthDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IAuthService
    {
        Task<Result> RegisterAsync(RegisterDto registerDto);
        Task<Results<string>> LoginAsync(LoginDto dto);
    }
}
