const SUPABASE_URL = "https://vdpucrilxzlnxxnaohdh.supabase.co"
const SUPABASE_KEY = "sb_publishable_iCOZMw9xc0QZaGQWTHdxMQ_O33nfE42"

const { createClient } = supabase
const db = createClient(SUPABASE_URL, SUPABASE_KEY)