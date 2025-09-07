using PicSocial.Server.Models.Interfaces;
using System;

namespace PicSocial.Server.Models.Entities
{
    public class Report : IDateTracking
    {
        public Guid ReportId { get; set; } = Guid.NewGuid();
        public Guid PhotoId { get; set; }
        public string UserId { get; set; } = null!;
        public string Reason { get; set; } = null!;
        public DateTimeOffset CreatedDate { get; set; }
        public DateTimeOffset? UpdatedDate { get; set; }
        public string Status { get; set; } = "Pending";

        // Navigation properties
        public Photo Photo { get; set; } = null!;
        public ApplicationUser User { get; set; } = null!;  
    }
}