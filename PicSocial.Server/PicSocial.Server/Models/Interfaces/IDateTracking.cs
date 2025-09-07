namespace PicSocial.Server.Models.Interfaces
{
    public interface IDateTracking
    {
        DateTimeOffset CreatedDate { get; set; }
        DateTimeOffset? UpdatedDate { get; set; }
    }
}
