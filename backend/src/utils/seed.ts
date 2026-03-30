/**
 * Seed script — run once after db:push
 * npx ts-node src/utils/seed.ts
 */
import 'dotenv/config';
import { prisma } from '../config/database';

const services = [
  { name: 'Digital Printing',      slug: 'digital-printing',       sortOrder: 1,  shortDescription: 'Fast, flexible, high-quality printing for short runs', features: ['Quick turnaround 24-48h', 'Vibrant CMYK colours', 'Any quantity', 'Free design check'] },
  { name: 'Offset Printing',       slug: 'offset-printing',        sortOrder: 2,  shortDescription: 'Large volume printing with consistent quality', features: ['Cost-effective at high volumes', 'Pantone colour matching', 'Premium paper stock', 'Perfect for 1000+ copies'] },
  { name: 'Screen Printing',       slug: 'screen-printing',        sortOrder: 3,  shortDescription: 'Bold designs on t-shirts, banners and specialty items', features: ['Thick vivid ink', 'Works on fabric & hard materials', 'Bulk discounts', 'Custom inks'] },
  { name: 'Large Format Printing', slug: 'large-format-printing',  sortOrder: 4,  shortDescription: 'Banners, posters and exhibition displays', features: ['Up to 5m wide', 'UV-resistant inks', 'Indoor & outdoor', 'Same-day available'] },
  { name: 'Custom Boxes',          slug: 'custom-boxes',           sortOrder: 5,  shortDescription: 'Custom packaging boxes in any size and shape', features: ['Die-cut shapes', 'Rigid & corrugated', 'Full colour print', 'Low MOQ'] },
  { name: 'Labels and Stickers',   slug: 'labels-stickers',        sortOrder: 6,  shortDescription: 'Any shape, size or material', features: ['Kiss-cut & die-cut', 'Waterproof options', 'Roll or sheet', 'Gloss & matt finish'] },
  { name: 'Bags and Pouches',      slug: 'bags-pouches',           sortOrder: 7,  shortDescription: 'Custom printed bags for retail and packaging', features: ['Paper, plastic & fabric', 'Custom handles', 'Spot UV available', 'Eco-friendly options'] },
  { name: 'Eco Friendly Packaging',slug: 'eco-friendly-packaging', sortOrder: 8,  shortDescription: 'Sustainable, recyclable, FSC-certified materials', features: ['100% recyclable', 'Biodegradable inks', 'FSC certified paper', 'Carbon offset printing'] },
  { name: 'Brand Identity',        slug: 'brand-identity',         sortOrder: 9,  shortDescription: 'Complete visual identity packages', features: ['Logo + brand guide', 'Business cards', 'Letterhead & envelope', 'Social media kit'] },
  { name: 'Logo Design',           slug: 'logo-design',            sortOrder: 10, shortDescription: 'Professional memorable logo design', features: ['Unlimited revisions', 'Vector files (AI/EPS)', '3 initial concepts', 'Full ownership'] },
  { name: 'Packaging Design',      slug: 'packaging-design',       sortOrder: 11, shortDescription: 'Eye-catching packaging that sells your product', features: ['3D mockups', 'Print-ready files', 'Dieline templates', 'Brand-aligned design'] },
  { name: 'Marketing Materials',   slug: 'marketing-materials',    sortOrder: 12, shortDescription: 'Brochures, flyers, catalogs and promotional print', features: ['Tri-fold & bi-fold', 'Premium paper stock', 'Bulk pricing', 'Free design support'] },
  { name: 'Business Printing',     slug: 'business-printing',      sortOrder: 13, shortDescription: 'Cards, letterheads, envelopes and stationery', features: ['Spot UV & foil', 'Thick 400gsm cards', 'Matching stationery set', 'Express 24h option'] },
  { name: 'Promotional Products',  slug: 'promotional-products',   sortOrder: 14, shortDescription: 'Branded merchandise and giveaways', features: ['Pens, mugs, bags', 'Event-ready turnaround', 'Custom packaging', 'Bulk discounts'] },
  { name: 'Speciality Printing',   slug: 'speciality-printing',    sortOrder: 15, shortDescription: 'Wedding cards, certificates, calendars and unique items', features: ['Gold/silver foiling', 'Embossing & debossing', 'Luxury paper stocks', 'Handcrafted finish'] },
  { name: 'Flexography',           slug: 'flexography',            sortOrder: 16, shortDescription: 'High-speed printing for flexible packaging', features: ['Food-safe inks', 'Flexible film & corrugated', 'High-speed production', 'Pantone accuracy'] },
];

const products = [
  { name: 'Business Cards',        slug: 'business-cards',          category: 'Business Printing', startingPrice: 1500,  priceUnit: 'per 100',    isFeatured: true },
  { name: 'Brochures',             slug: 'brochures',               category: 'Marketing',         startingPrice: 2500,  priceUnit: 'per 100' },
  { name: 'Flyers',                slug: 'flyers',                  category: 'Marketing',         startingPrice: 800,   priceUnit: 'per 100',    isFeatured: true },
  { name: 'Posters',               slug: 'posters',                 category: 'Large Format',      startingPrice: 1200,  priceUnit: 'per piece' },
  { name: 'Banners',               slug: 'banners',                 category: 'Large Format',      startingPrice: 2000,  priceUnit: 'per piece',  isFeatured: true },
  { name: 'Custom Boxes',          slug: 'custom-boxes',            category: 'Packaging',         startingPrice: 0,     priceUnit: 'custom quote', isFeatured: true },
  { name: 'Stickers and Labels',   slug: 'stickers-labels',         category: 'Labels',            startingPrice: 500,   priceUnit: 'per 100' },
  { name: 'Letterheads',           slug: 'letterheads',             category: 'Business Printing', startingPrice: 1200,  priceUnit: 'per 100' },
  { name: 'Envelopes',             slug: 'envelopes',               category: 'Business Printing', startingPrice: 900,   priceUnit: 'per 100' },
  { name: 'Presentation Folders',  slug: 'presentation-folders',    category: 'Business Printing', startingPrice: 3500,  priceUnit: 'per 50' },
  { name: 'Catalogs',              slug: 'catalogs',                category: 'Marketing',         startingPrice: 5000,  priceUnit: 'per 50' },
  { name: 'Roll-Up Banners',       slug: 'roll-up-banners',         category: 'Large Format',      startingPrice: 3500,  priceUnit: 'per piece',  isFeatured: true },
  { name: 'Window Graphics',       slug: 'window-graphics',         category: 'Large Format',      startingPrice: 0,     priceUnit: 'custom quote' },
  { name: 'Wall Graphics',         slug: 'wall-graphics',           category: 'Large Format',      startingPrice: 0,     priceUnit: 'custom quote' },
  { name: 'Shopping Bags',         slug: 'shopping-bags',           category: 'Packaging',         startingPrice: 2000,  priceUnit: 'per 100' },
  { name: 'Food Packaging',        slug: 'food-packaging',          category: 'Packaging',         startingPrice: 0,     priceUnit: 'custom quote', isFeatured: true },
  { name: 'Wedding Cards',         slug: 'wedding-cards',           category: 'Speciality',        startingPrice: 5000,  priceUnit: 'per 100',    isFeatured: true },
  { name: 'Calendars',             slug: 'calendars',               category: 'Speciality',        startingPrice: 1800,  priceUnit: 'per 50' },
  { name: 'Notepads',              slug: 'notepads',                category: 'Business Printing', startingPrice: 1500,  priceUnit: 'per 50' },
  { name: 'Certificates',          slug: 'certificates',            category: 'Speciality',        startingPrice: 2500,  priceUnit: 'per 100' },
  { name: 'Tissue Papers',         slug: 'tissue-papers',           category: 'Packaging',         startingPrice: 3000,  priceUnit: 'per 100' },
  { name: 'Bill Books',            slug: 'bill-books',              category: 'Business Printing', startingPrice: 1200,  priceUnit: 'per 50' },
  { name: 'Flag Printing',         slug: 'flag-printing',           category: 'Large Format',      startingPrice: 0,     priceUnit: 'custom quote' },
];

const categories = [
  { name: 'Business Printing', slug: 'business-printing', description: 'Cards, letterheads, and office materials', sortOrder: 1 },
  { name: 'Marketing',         slug: 'marketing',         description: 'Flyers, brochures, and promotional print', sortOrder: 2 },
  { name: 'Large Format',      slug: 'large-format',      description: 'Banners, posters, and signage', sortOrder: 3 },
  { name: 'Packaging',         slug: 'packaging',         description: 'Custom boxes, bags, and packaging', sortOrder: 4 },
  { name: 'Labels',            slug: 'labels',            description: 'Stickers, labels, and tags', sortOrder: 5 },
  { name: 'Speciality',        slug: 'speciality',        description: 'Wedding cards, certificates, and unique items', sortOrder: 6 },
];

const industries = [
  { name: 'Retail',          slug: 'retail',          description: 'Packaging, labels, and branding for retail', sortOrder: 1 },
  { name: 'Food & Beverage', slug: 'food-beverage',   description: 'Food-safe packaging, menus, and labels', sortOrder: 2 },
  { name: 'Healthcare',      slug: 'healthcare',      description: 'Medical brochures, labels, and compliance', sortOrder: 3 },
  { name: 'Corporate',       slug: 'corporate',       description: 'Office stationery and corporate materials', sortOrder: 4 },
];

const main = async () => {
  console.log('🌱  Seeding Fast Printing database...');

  // Categories
  for (const c of categories) {
    await prisma.category.upsert({ where: { slug: c.slug }, update: {}, create: c });
  }
  console.log(`✅  ${categories.length} categories seeded`);

  // Industries
  for (const i of industries) {
    await prisma.industry.upsert({ where: { slug: i.slug }, update: {}, create: i });
  }
  console.log(`✅  ${industries.length} industries seeded`);

  // Services
  for (const s of services) {
    await prisma.service.upsert({
      where: { slug: s.slug },
      update: {},
      create: {
        ...s,
        description: `${s.shortDescription}. Premium quality guaranteed with fast turnaround.`,
        isActive: true,
      },
    });
  }
  console.log(`✅  ${services.length} services seeded`);

  // Products
  for (const p of products) {
    await prisma.product.upsert({
      where: { slug: p.slug },
      update: {},
      create: {
        ...p,
        description: `Premium quality ${p.name} printed on high-grade materials. Available in multiple sizes and finishes.`,
        images: [],
        industries: [],
        isActive: true,
        isFeatured: p.isFeatured ?? false,
      },
    });
  }
  console.log(`✅  ${products.length} products seeded`);

  console.log('🎉  Seeding complete!');
};

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
