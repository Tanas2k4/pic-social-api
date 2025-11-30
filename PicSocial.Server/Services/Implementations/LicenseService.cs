using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{
    public class LicenseService : ILicenseService
    {
        private readonly ApplicationDbContext _context;
        public LicenseService(ApplicationDbContext context)
        {
            _context = context;
        }

        //Get all licenses
        public async Task<List<License>> GetAllLicensesAsync()
        {
            return await _context.Licenses.ToListAsync();
        }
    }
}
