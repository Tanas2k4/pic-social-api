using PicSocial.Server.DTOs.PostsDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IPostService
    {
        Task<Results<PostResponseDto>> UploadPhotoAsync(string currentUserId, string title, List<IFormFile> files, Guid? licenseId);
        Task<Result> DeletePostAsync(Guid postId, string currentUserId);
        Task<Results<PostResponseDto>> UpdatePostAsync(Guid postId, string currentUserId, string newTitle, Guid? licenseId);
        Task<Results<List<PostResponseDto>>> GetPostsByUserAsync(string userId);
        Task<Results<PostResponseDto>> GetPostByIdAsync(Guid postId);
    }
}
