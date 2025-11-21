using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface ICommentService
    {
        Task<Result<CommentCreateDto>> CommentPostAsync(Guid postId, string userId, string content, Guid? parentCommentId = null);
        Task<Result> DeleteCommentAsync(Guid commentId, string currentUserId);
        Task<Result<CommentUpdateDto>> UpdateCommentAsync(Guid commentId, string currentUserId, string newContent);
        Task<Result<List<CommentPostDto>>> GetCommentsByPostIdAsync(Guid postId);
    }
}
