using PicSocial.Server.DTOs.PostsDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IPostService
    {
        Task<Result<PostResponseDto>> UploadPhotoAsync(string currentUserId, string title, List<IFormFile> files);
        Task<Result> DeletePostAsync(Guid postId, string currentUserId);
        Task<Result<PostResponseDto>> UpdatePostAsync(Guid postId, string currentUserId, string newTitle);
        Task<Result<List<PostResponseDto>>> GetPostsByUserAsync(string userId);
        Task<Result<PostResponseDto>> GetPostByIdAsync(Guid postId);
    }
}
