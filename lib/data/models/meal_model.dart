class MealModel {
  final int id;
  final String name;
  final String? description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealModel({
    required this.id,
    required this.name,
    this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id:          (json['meal_id'] as num).toInt(),
      name:        json['name'] as String,
      description: json['description'] as String?,
      calories:    double.parse(json['calories'].toString()),
      protein:     double.parse(json['protein'].toString()),
      carbs:       double.parse(json['carbs'].toString()),
      fat:         double.parse(json['fat'].toString()),
    );
  }

  // Convert to FoodItem for use with existing FoodSwapService UI
 static String _emojiForMeal(String name) {
    final n = name.toLowerCase();

    // 🍗 Poultry
    if (n.contains('chicken') || n.contains('دجاج'))              return '🍗';
    if (n.contains('grilled chicken') || n.contains('دجاج مشوي')) return '🍗';
    if (n.contains('fried chicken') || n.contains('دجاج مقلي'))   return '🍗';
    if (n.contains('turkey') || n.contains('ديك رومي'))           return '🦃';
    if (n.contains('duck') || n.contains('بط'))                   return '🦆';

    // 🥩 Red Meat
    if (n.contains('beef') || n.contains('لحم بقري'))             return '🥩';
    if (n.contains('steak'))                                       return '🥩';
    if (n.contains('lamb') || n.contains('لحم ضاني') || n.contains('خروف')) return '🍖';
    if (n.contains('kofta') || n.contains('كفتة'))                return '🍖';
    if (n.contains('kebab') || n.contains('كباب'))                return '🍢';
    if (n.contains('liver') || n.contains('كبدة'))                return '🥩';
    if (n.contains('sausage') || n.contains('سجق'))               return '🌭';
    if (n.contains('hot dog'))                                     return '🌭';
    if (n.contains('bacon'))                                       return '🥓';
    if (n.contains('ribs') || n.contains('ضلوع'))                 return '🍖';

    // 🐟 Seafood
    if (n.contains('fish') || n.contains('سمك'))                  return '🐟';
    if (n.contains('tuna') || n.contains('تونة'))                 return '🐟';
    if (n.contains('salmon') || n.contains('سلمون'))              return '🍣';
    if (n.contains('shrimp') || n.contains('جمبري'))              return '🍤';
    if (n.contains('crab') || n.contains('كابوريا'))              return '🦀';
    if (n.contains('lobster') || n.contains('لوبستر'))            return '🦞';
    if (n.contains('squid') || n.contains('calamari') || n.contains('كالاماري')) return '🦑';
    if (n.contains('oyster') || n.contains('محار'))               return '🦪';
    if (n.contains('sushi') || n.contains('سوشي'))                return '🍣';

    // 🥚 Eggs & Dairy
    if (n.contains('egg') || n.contains('بيض'))                   return '🥚';
    if (n.contains('omelette') || n.contains('omelet') || n.contains('عجة')) return '🍳';
    if (n.contains('scrambled') || n.contains('بيض مخفوق'))       return '🍳';
    if (n.contains('boiled egg') || n.contains('بيض مسلوق'))      return '🥚';
    if (n.contains('milk') || n.contains('حليب') || n.contains('لبن')) return '🥛';
    if (n.contains('yogurt') || n.contains('زبادي'))              return '🫙';
    if (n.contains('cheese') || n.contains('جبنة') || n.contains('جبن')) return '🧀';
    if (n.contains('butter') || n.contains('زبدة'))               return '🧈';
    if (n.contains('cream') || n.contains('قشطة') || n.contains('كريمة')) return '🍦';
    if (n.contains('ice cream') || n.contains('ايس كريم'))        return '🍨';

    // 🥗 Salads & Vegetables
    if (n.contains('salad') || n.contains('سلطة'))                return '🥗';
    if (n.contains('caesar'))                                      return '🥗';
    if (n.contains('coleslaw'))                                    return '🥗';
    if (n.contains('lettuce') || n.contains('خس'))                return '🥬';
    if (n.contains('broccoli') || n.contains('بروكلي'))           return '🥦';
    if (n.contains('carrot') || n.contains('جزر'))                return '🥕';
    if (n.contains('corn') || n.contains('ذرة'))                  return '🌽';
    if (n.contains('tomato') || n.contains('طماطم'))              return '🍅';
    if (n.contains('cucumber') || n.contains('خيار'))             return '🥒';
    if (n.contains('pepper') || n.contains('فلفل'))               return '🫑';
    if (n.contains('mushroom') || n.contains('فطر'))              return '🍄';
    if (n.contains('onion') || n.contains('بصل'))                 return '🧅';
    if (n.contains('garlic') || n.contains('ثوم'))                return '🧄';
    if (n.contains('potato') || n.contains('بطاطس'))              return '🥔';
    if (n.contains('sweet potato') || n.contains('بطاطا حلوة'))   return '🍠';
    if (n.contains('avocado') || n.contains('أفوكادو'))           return '🥑';
    if (n.contains('eggplant') || n.contains('باذنجان'))          return '🍆';
    if (n.contains('spinach') || n.contains('سبانخ'))             return '🥬';
    if (n.contains('peas') || n.contains('بازلاء'))               return '🟢';
    if (n.contains('beans') || n.contains('فول') || n.contains('لوبيا')) return '🫘';
    if (n.contains('lentil') || n.contains('عدس'))                return '🫘';
    if (n.contains('chickpea') || n.contains('حمص'))              return '🫘';

    // 🍲 Soups & Stews
    if (n.contains('soup') || n.contains('شوربة'))                return '🍲';
    if (n.contains('stew') || n.contains('يخنة'))                 return '🫕';
    if (n.contains('broth') || n.contains('مرق'))                 return '🍵';
    if (n.contains('lentil soup') || n.contains('شوربة عدس'))     return '🍲';
    if (n.contains('tomato soup') || n.contains('شوربة طماطم'))   return '🍅';
    if (n.contains('chicken soup') || n.contains('شوربة دجاج'))   return '🍗';

    // 🍚 Rice & Grains
    if (n.contains('rice') || n.contains('أرز') || n.contains('رز')) return '🍚';
    if (n.contains('fried rice') || n.contains('أرز مقلي'))       return '🍳';
    if (n.contains('oat') || n.contains('شوفان'))                 return '🥣';
    if (n.contains('granola'))                                     return '🥣';
    if (n.contains('porridge') || n.contains('عصيدة'))            return '🥣';
    if (n.contains('quinoa') || n.contains('كينوا'))              return '🌾';
    if (n.contains('couscous') || n.contains('كسكسي'))            return '🍚';
    if (n.contains('freekeh') || n.contains('فريكة'))             return '🌾';

    // 🍝 Pasta & Noodles
    if (n.contains('pasta') || n.contains('باستا') || n.contains('مكرونة')) return '🍝';
    if (n.contains('spaghetti') || n.contains('سباغيتي'))         return '🍝';
    if (n.contains('lasagna') || n.contains('لازانيا'))           return '🍝';
    if (n.contains('noodle') || n.contains('نودلز'))              return '🍜';
    if (n.contains('ramen') || n.contains('رامن'))                return '🍜';
    if (n.contains('penne'))                                       return '🍝';

    // 🍞 Bread & Bakery
    if (n.contains('bread') || n.contains('خبز') || n.contains('عيش')) return '🍞';
    if (n.contains('toast') || n.contains('توست'))                return '🍞';
    if (n.contains('pita') || n.contains('خبز عربي'))             return '🫓';
    if (n.contains('croissant') || n.contains('كرواسون'))         return '🥐';
    if (n.contains('bagel') || n.contains('بيغل'))                return '🥯';
    if (n.contains('muffin') || n.contains('مافن'))               return '🧁';
    if (n.contains('pancake') || n.contains('بان كيك'))           return '🥞';
    if (n.contains('waffle') || n.contains('وافل'))               return '🧇';

    // 🥪 Fast Food & Sandwiches
    if (n.contains('sandwich') || n.contains('ساندويتش'))         return '🥪';
    if (n.contains('burger') || n.contains('برجر'))               return '🍔';
    if (n.contains('cheeseburger'))                                return '🍔';
    if (n.contains('wrap') || n.contains('راب'))                  return '🌯';
    if (n.contains('shawarma') || n.contains('شاورما'))           return '🌯';
    if (n.contains('falafel') || n.contains('فلافل'))             return '🧆';
    if (n.contains('pizza') || n.contains('بيتزا'))               return '🍕';
    if (n.contains('hot dog'))                                     return '🌭';
    if (n.contains('fries') || n.contains('بطاطس مقلية'))         return '🍟';
    if (n.contains('nugget') || n.contains('ناجتس'))              return '🍗';
    if (n.contains('taco') || n.contains('تاكو'))                 return '🌮';
    if (n.contains('burrito') || n.contains('بوريتو'))            return '🌯';
    if (n.contains('nachos'))                                      return '🧀';

    // 🍱 Asian & International
    if (n.contains('sushi') || n.contains('سوشي'))                return '🍣';
    if (n.contains('dumpling') || n.contains('ديمسام'))           return '🥟';
    if (n.contains('spring roll') || n.contains('سبرينج رول'))    return '🥢';
    if (n.contains('curry') || n.contains('كاري'))                return '🍛';
    if (n.contains('biryani') || n.contains('برياني'))            return '🍛';
    if (n.contains('hummus') || n.contains('حمص بطحينة'))         return '🫘';
    if (n.contains('tahini') || n.contains('طحينة'))              return '🥣';
    if (n.contains('moussaka') || n.contains('مسقعة'))            return '🍆';
    if (n.contains('stuffed') || n.contains('محشي'))              return '🫑';
    if (n.contains('koshari') || n.contains('كشري'))              return '🍚';
    if (n.contains('ful') || n.contains('فول مدمس'))              return '🫘';
    if (n.contains('molokheya') || n.contains('ملوخية'))          return '🥬';

    // 🍰 Desserts & Sweets
    if (n.contains('cake') || n.contains('كيك'))                  return '🎂';
    if (n.contains('chocolate') || n.contains('شوكولاتة'))        return '🍫';
    if (n.contains('cookie') || n.contains('كوكيز'))              return '🍪';
    if (n.contains('brownie') || n.contains('براوني'))            return '🍫';
    if (n.contains('donut') || n.contains('دونات'))               return '🍩';
    if (n.contains('pudding') || n.contains('بودينج'))            return '🍮';
    if (n.contains('pie') || n.contains('فطيرة'))                 return '🥧';
    if (n.contains('cheesecake') || n.contains('تشيز كيك'))       return '🍰';
    if (n.contains('candy') || n.contains('حلوى'))                return '🍬';
    if (n.contains('honey') || n.contains('عسل'))                 return '🍯';
    if (n.contains('konafa') || n.contains('كنافة'))              return '🍮';
    if (n.contains('baklava') || n.contains('بقلاوة'))            return '🍯';
    if (n.contains('halawa') || n.contains('حلاوة'))              return '🍬';
    if (n.contains('rice pudding') || n.contains('رز بلبن'))      return '🍚';

    // 🍎 Fruits
    if (n.contains('fruit') || n.contains('فاكهة'))               return '🍎';
    if (n.contains('apple') || n.contains('تفاح'))                return '🍎';
    if (n.contains('banana') || n.contains('موز'))                return '🍌';
    if (n.contains('orange') || n.contains('برتقال'))             return '🍊';
    if (n.contains('mango') || n.contains('مانجو'))               return '🥭';
    if (n.contains('strawberry') || n.contains('فراولة'))         return '🍓';
    if (n.contains('grape') || n.contains('عنب'))                 return '🍇';
    if (n.contains('watermelon') || n.contains('بطيخ'))           return '🍉';
    if (n.contains('pineapple') || n.contains('أناناس'))          return '🍍';
    if (n.contains('peach') || n.contains('خوخ'))                 return '🍑';
    if (n.contains('pear') || n.contains('كمثرى'))                return '🍐';
    if (n.contains('cherry') || n.contains('كرز'))                return '🍒';
    if (n.contains('lemon') || n.contains('ليمون'))               return '🍋';
    if (n.contains('dates') || n.contains('تمر') || n.contains('بلح')) return '🌴';
    if (n.contains('fig') || n.contains('تين'))                   return '🍈';

    // 🥜 Nuts & Seeds
    if (n.contains('nut') || n.contains('مكسرات'))                return '🥜';
    if (n.contains('almond') || n.contains('لوز'))                return '🥜';
    if (n.contains('walnut') || n.contains('جوز'))                return '🥜';
    if (n.contains('peanut') || n.contains('فول سوداني'))         return '🥜';
    if (n.contains('peanut butter') || n.contains('زبدة الفول'))  return '🥜';
    if (n.contains('seed') || n.contains('بذور'))                 return '🌰';
    if (n.contains('sunflower') || n.contains('عباد الشمس'))      return '🌻';

    // ☕ Hot Drinks
    if (n.contains('coffee') || n.contains('قهوة'))               return '☕';
    if (n.contains('espresso') || n.contains('اسبريسو'))          return '☕';
    if (n.contains('latte') || n.contains('لاتيه'))               return '🥛';
    if (n.contains('cappuccino') || n.contains('كابتشينو'))       return '☕';
    if (n.contains('tea') || n.contains('شاي'))                   return '🍵';
    if (n.contains('herbal') || n.contains('أعشاب'))              return '🌿';
    if (n.contains('matcha') || n.contains('ماتشا'))              return '🍵';
    if (n.contains('hot chocolate') || n.contains('شوكولاتة ساخنة')) return '🍫';

    // 🧃 Cold Drinks
    if (n.contains('juice') || n.contains('عصير'))                return '🧃';
    if (n.contains('smoothie') || n.contains('سموذي'))            return '🥤';
    if (n.contains('shake') || n.contains('شيك'))                 return '🥤';
    if (n.contains('protein shake') || n.contains('بروتين شيك'))  return '💪';
    if (n.contains('water') || n.contains('مياه') || n.contains('ماء')) return '💧';
    if (n.contains('soda') || n.contains('صودا'))                 return '🥤';
    if (n.contains('lemonade') || n.contains('ليمونادة'))         return '🍋';
    if (n.contains('coconut') || n.contains('جوز الهند'))         return '🥥';
    if (n.contains('milk shake') || n.contains('ميلك شيك'))       return '🥛';

    // 🌿 Health & Diet
    if (n.contains('protein') || n.contains('بروتين'))            return '💪';
    if (n.contains('diet') || n.contains('دايت'))                 return '🥗';
    if (n.contains('vegan') || n.contains('نباتي'))               return '🌱';
    if (n.contains('detox') || n.contains('ديتوكس'))              return '🌿';
    if (n.contains('supplement') || n.contains('مكمل'))           return '💊';

    // 🍽️ Default fallback
    return '🍽️';
  }
}

// Lightweight compat class so MealModel works with existing FoodItem UI
class FoodItemCompat {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;

  const FoodItemCompat({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
  });
}