namespace PicSocial.Server.Models.Entities
{
    public class License
    {
        public Guid LicenseId { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = null!;
        public string? Description { get; set; } 

        // Navigation property
        public ICollection<PhotoLicense> PhotoLicenses { get; set; } = new List<PhotoLicense>();
    }
}