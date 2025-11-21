using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IReportService
    {
        Task<Result> ReportPostAsync(Guid postId, string userId, string reason);
    }
}
