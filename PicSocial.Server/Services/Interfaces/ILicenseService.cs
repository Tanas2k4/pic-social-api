using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Services.Interfaces
{
    public interface ILicenseService
    {
        Task<List<License>> GetAllLicensesAsync();
    }
}
