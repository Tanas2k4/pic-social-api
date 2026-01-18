using MetadataExtractor;
using MetadataExtractor.Formats.Xmp;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using System.Text.Json;
using XmpCore;

public class PhotoXmpMetadataService : IPhotoXmpMetadataService
{
    private const string NS_XMP = "http://ns.adobe.com/xap/1.0/";
    private const string NS_DC = "http://purl.org/dc/elements/1.1/";


    public PhotoXmpMetadata? ExtractXmp(Stream stream)
    {
        if (stream.CanSeek)
            stream.Position = 0;

        var directories = ImageMetadataReader.ReadMetadata(stream);
        var xmpDir = directories.OfType<XmpDirectory>().FirstOrDefault();

        if (xmpDir?.XmpMeta == null)
            return null;

        var xmp = xmpDir.XmpMeta;
        var keywords = GetKeywords(xmp);

        return new PhotoXmpMetadata
        {
            RawXmp = xmpDir.ToString(),
            Rating = xmp.GetPropertyInteger(NS_XMP, "Rating"),
            Title = xmp.GetLocalizedText(NS_DC, "title", null, "x-default")?.Value,
            Caption = xmp.GetLocalizedText(NS_DC, "description", null, "x-default")?.Value,
            KeywordsJson = keywords.Count > 0
                ? JsonSerializer.Serialize(keywords)
                : null,
            ColorLabel = xmp.GetPropertyString(NS_XMP, "Label")
        };
    }

    // Helper method to extract keywords from XMP metadata
    private List<string> GetKeywords(IXmpMeta xmpMeta)
    {
        var keywords = new List<string>();
        var count = xmpMeta.CountArrayItems(NS_DC, "subject");
        
        // If no keywords found, return empty list
        for (int i = 1; i <= count; i++)
        {
            var item = xmpMeta.GetArrayItem(NS_DC, "subject", i);
            if (!string.IsNullOrWhiteSpace(item?.Value))
                keywords.Add(item.Value);
        }

        return keywords;
    }
}
