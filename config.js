const SUPABASE_URL = "https://vdpucrilxzlnxxnaohdh.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkcHVjcmlseHpsbnh4bmFvaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI0OTc0NzIsImV4cCI6MjA4ODA3MzQ3Mn0.hdGtfK0eQf0-Iu_LqYqKKLvt8189euaGy-mmGMALJ_I"

const { createClient } = supabase
const db = createClient(SUPABASE_URL, SUPABASE_KEY)