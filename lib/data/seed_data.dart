import '../models/diary_entry.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';

/// Initial diary entries — used when no persisted data exists.
/// Mirrors `DIARY_SAMPLES` in Omnom.html lines 47–54, with strict typing:
/// empty strings become null, numeric strings parse to int/double.
const List<DiaryEntry> seedDiaryEntries = [
  DiaryEntry(
    id: 's1',
    title: 'Mushroom Risotto',
    desc: 'Creamy and rich, used dried porcini for extra depth.',
    date: '2026-04-20',
    meal: 'Dinner',
    tags: ['italian', 'rice', 'vegetarian'],
    r1: 9,
    r2: 8,
    activeTime: 40,
    price: 12.50,
    country: 'Italy',
  ),
  DiaryEntry(
    id: 's2',
    title: 'Shakshuka',
    desc: 'Spiced tomato sauce, perfectly runny eggs.',
    date: '2026-04-17',
    meal: 'Breakfast',
    tags: ['eggs', 'spicy', 'quick'],
    r1: 8,
    r2: 9,
    activeTime: 20,
    passiveTime: 10,
    price: 6.00,
    country: 'Israel',
  ),
  DiaryEntry(
    id: 's3',
    title: 'Slow-cooked Lamb Shoulder',
    desc: 'Eight hours in the oven. Fell off the bone.',
    date: '2026-04-13',
    meal: 'Dinner',
    tags: ['lamb', 'slow cook', 'sunday'],
    r1: 10,
    r2: 10,
    activeTime: 25,
    passiveTime: 480,
    price: 22.00,
  ),
  DiaryEntry(
    id: 's4',
    title: 'Avocado Toast',
    desc: 'Simple but elevated with chilli flakes and a poached egg.',
    date: '2026-04-10',
    meal: 'Breakfast',
    tags: ['quick', 'eggs', 'simple'],
    r1: 7,
    r2: 7,
    activeTime: 10,
    price: 4.50,
  ),
  DiaryEntry(
    id: 's5',
    title: 'Thai Green Curry',
    desc: 'Homemade paste makes all the difference.',
    date: '2026-04-06',
    meal: 'Dinner',
    tags: ['thai', 'spicy', 'coconut'],
    r1: 9,
    r2: 8,
    activeTime: 35,
    passiveTime: 15,
    price: 14.00,
    country: 'Thailand',
  ),
  DiaryEntry(
    id: 's6',
    title: 'Pasta e Fagioli',
    desc: 'Humble, hearty, perfect for a cold evening.',
    date: '2026-03-30',
    meal: 'Dinner',
    tags: ['italian', 'pasta', 'beans'],
    r1: 8,
    r2: 9,
    activeTime: 30,
    passiveTime: 60,
    price: 7.00,
    country: 'Italy',
  ),
];

/// Initial recipes — RECIPE_SAMPLES in Omnom.html lines 57–99.
const List<Recipe> seedRecipes = [
  Recipe(
    id: 'r1',
    title: 'Spaghetti Carbonara',
    description:
        'A classic Roman pasta dish. Silky, rich, no cream needed.',
    servings: '2',
    country: 'Italy',
    tags: ['pasta', 'italian', 'quick'],
    activeTime: 20,
    price: 8.00,
    ingredients: [
      Ingredient(id: 'i1', qty: '200', unit: 'g', name: 'spaghetti'),
      Ingredient(id: 'i2', qty: '100', unit: 'g', name: 'guanciale or pancetta'),
      Ingredient(id: 'i3', qty: '2', name: 'egg yolks'),
      Ingredient(id: 'i4', qty: '1', name: 'whole egg'),
      Ingredient(id: 'i5', qty: '50', unit: 'g', name: 'Pecorino Romano, grated'),
      Ingredient(id: 'i6', name: 'black pepper, generous amount'),
    ],
    steps: [
      RecipeStep(
        id: 'rs1',
        text:
            'Bring a large pot of salted water to the boil and cook spaghetti until al dente.',
      ),
      RecipeStep(
        id: 'rs2',
        text:
            'Fry guanciale in a dry pan over medium heat until crispy. Remove from heat.',
      ),
      RecipeStep(
        id: 'rs3',
        text:
            'Whisk egg yolks, whole egg and Pecorino together with plenty of black pepper.',
      ),
      RecipeStep(
        id: 'rs4',
        text:
            'Reserve a cup of pasta water. Drain pasta and toss in the pan with the guanciale off the heat.',
      ),
      RecipeStep(
        id: 'rs5',
        text:
            'Add the egg mixture and a splash of pasta water, stirring quickly to create a creamy sauce. Serve immediately.',
      ),
    ],
  ),
  Recipe(
    id: 'r2',
    title: 'Roasted Tomato Soup',
    description: 'Depth from roasting. Blend until silky smooth.',
    servings: '4',
    tags: ['soup', 'vegetarian', 'comfort'],
    activeTime: 15,
    passiveTime: 40,
    price: 6.50,
    ingredients: [
      Ingredient(id: 'i7', qty: '800', unit: 'g', name: 'ripe tomatoes, halved'),
      Ingredient(id: 'i8', qty: '1', name: 'whole garlic bulb'),
      Ingredient(id: 'i9', qty: '1', name: 'onion, quartered'),
      Ingredient(id: 'i10', qty: '3', unit: 'tbsp', name: 'olive oil'),
      Ingredient(id: 'i11', qty: '500', unit: 'ml', name: 'vegetable stock'),
      Ingredient(id: 'i12', qty: '1', unit: 'tsp', name: 'sugar'),
    ],
    steps: [
      RecipeStep(
        id: 'rs6',
        text:
            'Preheat oven to 200°C. Place tomatoes, garlic bulb and onion on a baking tray, drizzle with olive oil and roast for 40 minutes.',
      ),
      RecipeStep(
        id: 'rs7',
        text: 'Squeeze the roasted garlic cloves out of their skins.',
      ),
      RecipeStep(
        id: 'rs8',
        text: 'Transfer everything to a blender with the stock and blitz until smooth.',
      ),
      RecipeStep(
        id: 'rs9',
        text:
            'Season with salt, pepper and sugar. Reheat gently and serve with crusty bread.',
      ),
    ],
  ),
];
