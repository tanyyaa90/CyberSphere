package model;

import java.util.regex.Pattern;

public class PhishingPattern {

    private Pattern pattern;
    private int weight;
    private String description;

    public PhishingPattern(Pattern pattern, int weight, String description) {
        this.pattern = pattern;
        this.weight = weight;
        this.description = description;
    }

    public Pattern getPattern() {
        return pattern;
    }

    public int getWeight() {
        return weight;
    }

    public String getDescription() {
        return description;
    }
}
