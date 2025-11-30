namespace PicSocial.Server.DTOs.TagDto
{
    public class TagDto
    {
        public Guid TagId { get; set; }
        public string Name { get; set; } = null!;
        public string? Type { get; set; } // Ví dụ: "Category", "Location", "Person", etc.
    }
}
