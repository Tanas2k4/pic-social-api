using Microsoft.AspNetCore.Identity;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class AvatarService : IAvatarService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly GoogleCloudStorageService _googleCloudStorageService;

        public AvatarService(UserManager<ApplicationUser> userManager, GoogleCloudStorageService googleCloudStorageService)
        {
            _userManager = userManager;
            _googleCloudStorageService = googleCloudStorageService;
        }

        //upload avatar
        public async Task<Result> UploadAvatarAsync(string currentUserId, IFormFile avatar)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)         
                return Result.Unauthorized("Unauthorized");

            //Kiểm tra file được tải lên
            if (avatar == null)
                return Result.Bad("No file uploaded");

            //Xóa avatar cũ nếu có để ghì đè avetar mới
            if (!string.IsNullOrEmpty(currentUser.AvatarUrl))
            {
                var oldAvatar = Path.GetFileName(currentUser.AvatarUrl);
                await _googleCloudStorageService.DeleteFileAsync($"avatars/{oldAvatar}");
            }
            var objectName = $"avatars/{Guid.NewGuid()}{Path.GetExtension(avatar.FileName)}";
            var fileUrl = await _googleCloudStorageService.UploadFileAsync(
                avatar.OpenReadStream(),
                objectName,
                avatar.ContentType
            );

            currentUser.AvatarUrl = fileUrl;
            await _userManager.UpdateAsync(currentUser);

            return Result.Ok("Avatar uploaded successfully");
        }

        //delete avatar
        public async Task<Result> DeleteAvatarAsync(string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)            
                return Result.Unauthorized("Unauthorized");

            if (string.IsNullOrEmpty(currentUser.AvatarUrl))          
                return Result.Bad("No avatar to delete");

            //Xóa avatar khỏi Google Cloud Storage
            var objectName = Path.GetFileName(currentUser.AvatarUrl);
            await _googleCloudStorageService.DeleteFileAsync($"avatars/{objectName}");
            
            currentUser.AvatarUrl = null; // Ở đây có thể thay thế thành avatar mặc định nếu cần
            await _userManager.UpdateAsync(currentUser);
            return Result.Ok("Avatar deleted successfully");
        }
    }
}
