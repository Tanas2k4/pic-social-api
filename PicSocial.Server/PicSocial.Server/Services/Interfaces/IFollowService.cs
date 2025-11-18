namespace PicSocial.Server.Services.Interfaces
{
    public interface IFollowService
    {
        Task<bool> IsFollowingAsync(string currentUserId, string targetUserId);
    }
}
