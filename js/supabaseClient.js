const SUPABASE_URL = "https://emzqqvoqqodaggskgfze.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_rYu-TFnQacUrnmdNVRZ3Zw_wR3r_u4W";

const DEV_EMAILS = [
  'admin@grammi.app',
  'dev@grammi.app'
];

const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);