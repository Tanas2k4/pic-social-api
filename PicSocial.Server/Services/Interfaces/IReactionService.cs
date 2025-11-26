using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IReactionService
    {
        Task<Result> ReactionPostAsync(string userId, Guid postId);
    }
}
