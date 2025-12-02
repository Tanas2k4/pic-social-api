using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.PhotosDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    
    public class PhotoController : ControllerBase
    {
        private readonly IPhotoService _photoService;
        private readonly UserManager<ApplicationUser> _userManager;
        public PhotoController(IPhotoService photoService, UserManager<ApplicationUser> userManager)
        {
            _photoService = photoService;
            _userManager = userManager;
        }

        //Chỉnh sửa thông tin ảnh
        [HttpPatch("{photoId}")]
        public async Task<IActionResult> UpdatePhoto(Guid photoId, [FromBody] PhotoUpdateDto dto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null) 
                return Unauthorized();

            var result = await _photoService.UpdatePhotoAsync(photoId, currentUser.Id, dto);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}
