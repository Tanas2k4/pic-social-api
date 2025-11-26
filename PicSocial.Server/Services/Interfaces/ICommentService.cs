using PicSocial.Server.DTOs.CommentsDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface ICommentService
    {
        Task<Results<CommentCreateDto>> CommentPostAsync(Guid postId, string userId, string content, Guid? parentCommentId = null);
        Task<Result> DeleteCommentAsync(Guid commentId, string currentUserId);
        Task<Results<CommentUpdateDto>> UpdateCommentAsync(Guid commentId, string currentUserId, string newContent);
        Task<Results<List<CommentPostDto>>> GetCommentsByPostIdAsync(Guid postId);
    }
}
