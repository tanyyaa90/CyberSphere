package model;

public class LearningContent {

    private String level;
    private String topic;
    private String type; // e.g., "video", "image", "article"
    private String url;

    // default constructor
    public LearningContent() {
    }

    // constructor with all fields
    public LearningContent(String level, String topic, String type, String url) {
        this.level = level;
        this.topic = topic;
        this.type = type;
        this.url = url;
    }

    // getters and setters
    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

}
