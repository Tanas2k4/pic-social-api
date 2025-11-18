using Microsoft.AspNetCore.Mvc;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IReactionService
    {
        Task<string> ReactionPostAsync(string userId, Guid postId);
    }
}
