-- Database schema for Property Agent Customer Management
-- Compatible with PostgreSQL

-- Customer Profiles Table
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) UNIQUE NOT NULL, -- Telegram/WhatsApp user ID
    platform VARCHAR(20) NOT NULL, -- 'telegram' or 'whatsapp'
    phone_number VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    username VARCHAR(100),
    language_code VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer Preferences Table
CREATE TABLE IF NOT EXISTS customer_preferences (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES customers(customer_id) ON DELETE CASCADE,
    budget_min DECIMAL(12, 2),
    budget_max DECIMAL(12, 2),
    preferred_areas TEXT[], -- Array of area names
    property_type VARCHAR(50), -- 'condo', 'landed', 'commercial', 'mixed'
    bedrooms INTEGER,
    purpose VARCHAR(50), -- 'own_stay', 'investment', 'both'
    preferred_contact_time VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversation History Table
CREATE TABLE IF NOT EXISTS conversation_history (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES customers(customer_id) ON DELETE CASCADE,
    message_id VARCHAR(100),
    direction VARCHAR(20), -- 'inbound' or 'outbound'
    message_text TEXT,
    intent VARCHAR(50), -- classified intent
    sentiment VARCHAR(20), -- 'positive', 'neutral', 'negative'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Property Interactions Table (track which properties were shown to customers)
CREATE TABLE IF NOT EXISTS property_interactions (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) REFERENCES customers(customer_id) ON DELETE CASCADE,
    property_id VARCHAR(100),
    property_name VARCHAR(255),
    property_area VARCHAR(100),
    property_price DECIMAL(12, 2),
    interaction_type VARCHAR(50), -- 'viewed', 'interested', 'scheduled_viewing', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Decision Tree State Table (track where customer is in conversation flow)
CREATE TABLE IF NOT EXISTS decision_tree_state (
    id SERIAL PRIMARY KEY,
    customer_id VARCHAR(100) UNIQUE REFERENCES customers(customer_id) ON DELETE CASCADE,
    current_node VARCHAR(100), -- current position in decision tree
    context JSONB, -- store additional context data
    waiting_for VARCHAR(100), -- what information we're waiting for
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Analytics Table
CREATE TABLE IF NOT EXISTS analytics (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50), -- 'message_received', 'response_sent', 'intent_classified', etc.
    customer_id VARCHAR(100),
    metadata JSONB,
    response_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_customers_customer_id ON customers(customer_id);
CREATE INDEX IF NOT EXISTS idx_conversation_customer_id ON conversation_history(customer_id);
CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON conversation_history(created_at);
CREATE INDEX IF NOT EXISTS idx_property_interactions_customer_id ON property_interactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics(created_at);
