using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.AuthDto;
using PicSocial.Server.DTOs.CommentsDto;
using PicSocial.Server.Services.Interfaces;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Register a new user account.
    /// </summary>
    /// <remarks>
    /// Creates a new user using email and password.
    /// </remarks>
    /// <param name="registerDto">User registration information</param>
    /// <response code="201">User registered successfully</response>
    /// <response code="400">Invalid registration data</response>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDto registerDto)
    {
        var result = await _authService.RegisterAsync(registerDto);
        return StatusCode(result.StatusCode, result);
    }

    /// <summary>
    /// Login with email and password.
    /// </summary>
    /// <remarks>
    /// Returns a JWT access token if credentials are valid.
    /// </remarks>
    /// <param name="loginDto">User login credentials</param>
    /// <response code="200">Login successful</response>
    /// <response code="401">Invalid email or password</response>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
    {
        var result = await _authService.LoginAsync(loginDto);
        return StatusCode(result.StatusCode, result);
    }
}