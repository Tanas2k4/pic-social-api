using System;

namespace PicSocial.Server.Models.Entities
{
    public class PhotoLicense
    {
        public Guid PhotoLicenseId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public Guid LicenseId { get; set; }
        public string? WatermarkText { get; set; } //Chữ ký bản quyền
        public string? WatermarkPosition { get; set; } // Vị trí chữ ký bản quyền: Top-Left, Top-Right, Bottom-Left, Bottom-Right, Center

        // Navigation properties
        public Photo Photo { get; set; } = null!;
        public License License { get; set; } = null!;
    }
}