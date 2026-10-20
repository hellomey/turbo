import { z } from "../zod.js";

/** Highest completed qualification (blueprint §19.1 Q5). Ordered from lowest to highest. */
export const QUALIFICATIONS = ["sslc", "hsc", "iti", "diploma", "degree", "pg"] as const;
export const Qualification = z.enum(QUALIFICATIONS).openapi("Qualification");
export type Qualification = z.infer<typeof Qualification>;

/** Tamil Nadu community categories used in TNPSC notifications. */
export const COMMUNITIES = ["OC", "BC", "BCM", "MBC_DNC", "SC", "SCA", "ST"] as const;
export const Community = z.enum(COMMUNITIES).openapi("Community");
export type Community = z.infer<typeof Community>;

export const SPECIAL_CATEGORIES = ["PWD", "EX_SERVICEMAN", "DESTITUTE_WIDOW"] as const;
export const SpecialCategory = z.enum(SPECIAL_CATEGORIES).openapi("SpecialCategory");
export type SpecialCategory = z.infer<typeof SpecialCategory>;

/** The 38 districts of Tamil Nadu. The user picks one; we never collect location (§23). */
export const TN_DISTRICTS = [
  "Ariyalur", "Chengalpattu", "Chennai", "Coimbatore", "Cuddalore", "Dharmapuri", "Dindigul", "Erode",
  "Kallakurichi", "Kancheepuram", "Kanyakumari", "Karur", "Krishnagiri", "Madurai", "Mayiladuthurai",
  "Nagapattinam", "Namakkal", "Nilgiris", "Perambalur", "Pudukkottai", "Ramanathapuram", "Ranipet", "Salem",
  "Sivaganga", "Tenkasi", "Thanjavur", "Theni", "Thoothukudi", "Tiruchirappalli", "Tirunelveli", "Tirupathur",
  "Tiruppur", "Tiruvallur", "Tiruvannamalai", "Tiruvarur", "Vellore", "Viluppuram", "Virudhunagar",
] as const;
export const District = z.enum(TN_DISTRICTS).openapi("District");
export type District = z.infer<typeof District>;

export const ROLES = [
  "VISITOR", "ASPIRANT", "SUPPORTER", "MENTOR", "CREATOR", "REVIEWER", "PUBLISHER", "INSTITUTION_ADMIN",
  "SUPPORT_AGENT", "MODERATOR", "OPS", "ADMIN", "SYSTEM",
] as const;
export const Role = z.enum(ROLES).openapi("Role");
export type Role = z.infer<typeof Role>;

/** Roles that may use HeyMey Desk (blueprint §15). Aspirants never can. */
export const DESK_ROLES: readonly Role[] = [
  "CREATOR", "REVIEWER", "PUBLISHER", "INSTITUTION_ADMIN", "SUPPORT_AGENT", "MODERATOR", "OPS", "ADMIN",
];
