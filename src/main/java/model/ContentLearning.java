package model;

public class ContentLearning {

    private String title;
    private String type;
    private String link;
    private String thumbnail;
    private String category;

    public ContentLearning(String title, String type, String link,
                           String thumbnail, String category) {
        this.title = title;
        this.type = type;
        this.link = link;
        this.thumbnail = thumbnail;
        this.category = category;
    }

    public String getTitle() { return title; }
    public String getType() { return type; }
    public String getLink() { return link; }
    public String getThumbnail() { return thumbnail; }
    public String getCategory() { return category; }
}
