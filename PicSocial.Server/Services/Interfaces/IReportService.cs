namespace PicSocial.Server.Services.Interfaces
{
    public interface IReportService
    {
        Task<bool> ReportPostAsync(Guid postId, string userId, string reason);
    }
}
