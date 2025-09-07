using System;

namespace PicSocial.Server.Models.Entities
{
    public class PhotoLicense
    {
        public Guid PhotoLicenseId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public Guid LicenseId { get; set; }
        public string? WatermarkText { get; set; }
        public string? WatermarkPosition { get; set; }

        // Navigation properties
        public Photo Photo { get; set; } = null!;
        public License License { get; set; } = null!;
    }
}