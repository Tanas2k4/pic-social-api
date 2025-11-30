namespace PicSocial.Server.DTOs.PhotosDto
{
    public class PhotoLicenseDto
    {
        public Guid LicenseId { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? WatermarkText { get; set; } // Chữ ký bản quyền
        public string? WatermarkPosition { get; set; } // Vị trí chữ ký bản quyền: Top-Left, Top-Right, Bottom-Left, Bottom-Right, Center
    }
}
