
String guessFoodEmoji(String name) {
  final n = name.toLowerCase();

  if (n.contains('دجاج') || n.contains('فراخ') || n.contains('فرخة') || n.contains('فرخ'))    return '🍗';
  if (n.contains('ديك رومي'))                                              return '🦃';
  if (n.contains('بط'))                                                    return '🦆';

  if (n.contains('كباب'))                                                  return '🍢';
  if (n.contains('كفتة'))                                                  return '🍖';
  if (n.contains('لحم ضاني') || n.contains('خروف'))                       return '🍖';
  if (n.contains('ضلوع'))                                                  return '🍖';
  if (n.contains('كبدة'))                                                  return '🥩';
  if (n.contains('سجق'))                                                   return '🌭';
  if (n.contains('لحم'))                                                   return '🥩';

  if (n.contains('جمبري'))                                                 return '🍤';
  if (n.contains('كابوريا'))                                               return '🦀';
  if (n.contains('لوبستر'))                                                return '🦞';
  if (n.contains('كالاماري'))                                              return '🦑';
  if (n.contains('محار'))                                                  return '🦪';
  if (n.contains('سلمون'))                                                 return '🍣';
  if (n.contains('تونة'))                                                  return '🐟';
  if (n.contains('سمك'))                                                   return '🐟';
  if (n.contains('سوشي'))                                                  return '🍣';

  if (n.contains('عجة') || n.contains('بيض مخفوق'))                       return '🍳';
  if (n.contains('بيض مسلوق'))                                             return '🥚';
  if (n.contains('بيض'))                                                   return '🥚';
  if (n.contains('زبادي') || n.contains('زبادى') ||
      n.contains('مشروب الزبادي') || n.contains('سلطة الخيار بالزبادي') ||
      n.contains('خيار بالزبادي') || n.contains('خيار بالزبادى'))          return '🫙';
  if (n.contains('جبنة') || n.contains('جبن'))                            return '🧀';
  if (n.contains('زبدة'))                                                  return '🧈';
  if (n.contains('قشطة') || n.contains('كريمة'))                          return '🍦';
  if (n.contains('ايس كريم') || n.contains('آيس كريم'))                   return '🍨';
  if (n.contains('حليب') || n.contains('لبن'))                            return '🥛';

  if (n.contains('سلطة'))                                                  return '🥗';
  if (n.contains('خس'))                                                    return '🥬';
  if (n.contains('بروكلي'))                                                return '🥦';
  if (n.contains('جزر'))                                                   return '🥕';
  if (n.contains('ذرة'))                                                   return '🌽';
  if (n.contains('طماطم'))                                                 return '🍅';
  if (n.contains('خيار'))                                                  return '🥒';
  if (n.contains('فلفل'))                                                  return '🫑';
  if (n.contains('فطر'))                                                   return '🍄';
  if (n.contains('بصل'))                                                   return '🧅';
  if (n.contains('ثوم'))                                                   return '🧄';
  if (n.contains('بطاطا حلوة'))                                            return '🍠';
  if (n.contains('بطاطس'))                                                 return '🥔';
  if (n.contains('أفوكادو') || n.contains('افوكادو'))                     return '🥑';
  if (n.contains('باذنجان'))                                               return '🍆';
  if (n.contains('سبانخ'))                                                 return '🥬';
  if (n.contains('بازلاء') || n.contains('بازلا'))                                                return '🟢';
  if (n.contains('عدس'))                                                   return '🫘';
  if (n.contains('فول سودانى') || n.contains('فول سوداني') ||
      n.contains('فول السودانى') || n.contains('فول السوداني'))            return '🥜';
  if (n.contains('فول مدمس') || n.contains('فول بالزيت') ||
      n.contains('فول بالشطة') || n.contains('فول بالسمن') ||
      n.contains('فول اخضر') || n.contains('فول أخضر') ||
      n.contains('فول نابت') || n.contains('طبق فول') ||
      n.contains('شوربة الفول') || n.contains('فول مشكل') ||
      n.contains('فول'))                                                    return '🫘';
  if (n.contains('لوبيا'))                                                 return '🫘';
  if (n.contains('حمص'))                                                   return '🫘';

  if (n.contains('شوربة'))                                                 return '🍲';
  if (n.contains('طاجن') || n.contains('كوارع'))                                                  return '🍲';
  if (n.contains('يخنة'))                                                  return '🫕';
  if (n.contains('مرق'))                                                   return '🍵';

  if (n.contains('أرز مقلي'))                                              return '🍳';
  if (n.contains('أرز') || n.contains('ارز') || n.contains('رز'))                              return '🍚';
  if (n.contains('شوفان'))                                                 return '🥣';
  if (n.contains('عصيدة'))                                                 return '🥣';
  if (n.contains('كينوا'))                                                 return '🌾';
  if (n.contains('كسكسي'))                                                 return '🍚';
  if (n.contains('فريكة'))                                                 return '🌾';
  if (n.contains('كشري'))                                                  return '🍚';

  if (n.contains('مكرونة') || n.contains('باستا'))                        return '🍝';
  if (n.contains('سباغيتي'))                                               return '🍝';
  if (n.contains('لازانيا'))                                               return '🍝';
  if (n.contains('نودلز'))                                                 return '🍜';
  if (n.contains('رامن'))                                                  return '🍜';

  if (n.contains('كرواسون'))                                               return '🥐';
  if (n.contains('مافن'))                                                  return '🧁';
  if (n.contains('بان كيك'))                                               return '🥞';
  if (n.contains('وافل'))                                                  return '🧇';
  if (n.contains('توست'))                                                  return '🍞';
  if (n.contains('خبز عربي') || n.contains('عيش بلدي'))                   return '🫓';
  if (n.contains('زعتر'))                                                   return '🫓';
  if (n.contains('رغيف') || n.contains('خبز') || n.contains('عيش'))      return '🍞';

  if (n.contains('ساندوتش') || n.contains('ساندويتش') || n.contains('سندوتش'))                    return '🥪';
  if (n.contains('برجر'))                                                  return '🍔';
  if (n.contains('شاورما'))                                                return '🌯';
  if (n.contains('فلافل'))                                                 return '🧆';
  if (n.contains('بيتزا'))                                                 return '🍕';
  if (n.contains('بطاطس مقلية'))                                           return '🍟';
  if (n.contains('ناجتس'))                                                 return '🍗';
  if (n.contains('تاكو'))                                                  return '🌮';
  if (n.contains('بوريتو'))                                                return '🌯';
  if (n.contains('محشو') || n.contains('محشي'))                           return '🫑';
  if (n.contains('مسقعة'))                                                 return '🍆';
  if (n.contains('ملوخية'))                                                return '🥬';
  if (n.contains('طحينة'))                                                 return '🥣';
  if (n.contains('كاري'))                                                  return '🍛';
  if (n.contains('برياني'))                                                return '🍛';

  if (n.contains('كنافة'))                                                 return '🍮';
  if (n.contains('بقلاوة'))                                                return '🍯';
  if (n.contains('حلاوة'))                                                 return '🍬';
  if (n.contains('رز بلبن'))                                               return '🍚';
  if (n.contains('بودينج'))                                                return '🍮';
  if (n.contains('فطيرة'))                                                 return '🥧';
  if (n.contains('تشيز كيك'))                                              return '🍰';
  if (n.contains('دونات'))                                                 return '🍩';
  if (n.contains('براوني'))                                                return '🍫';
  if (n.contains('كوكيز'))                                                 return '🍪';
  if (n.contains('كيك'))                                                   return '🎂';
  if (n.contains('شوكولاتة'))                                              return '🍫';
  if (n.contains('حلوى'))                                                  return '🍬';
  if (n.contains('عسل'))                                                   return '🍯';

  if (n.contains('فراولة'))                                                return '🍓';
  if (n.contains('مانجو'))                                                 return '🥭';
  if (n.contains('بطيخ'))                                                  return '🍉';
  if (n.contains('أناناس'))                                                return '🍍';
  if (n.contains('برتقال'))                                                return '🍊';
  if (n.contains('موز'))                                                   return '🍌';
  if (n.contains('تفاح'))                                                  return '🍎';
  if (n.contains('عنب'))                                                   return '🍇';
  if (n.contains('خوخ'))                                                   return '🍑';
  if (n.contains('كمثرى'))                                                 return '🍐';
  if (n.contains('كرز'))                                                   return '🍒';
  if (n.contains('ليمون'))                                                 return '🍋';
  if (n.contains('تمر') || n.contains('بلح'))                             return '🌴';
  if (n.contains('تين'))                                                   return '🍈';
  if (n.contains('فاكهة'))                                                 return '🍎';

  if (n.contains('لوز'))                                                   return '🥜';
  if (n.contains('جوز'))                                                   return '🥜';
  if (n.contains('فول سوداني'))                                            return '🥜';
  if (n.contains('زبدة الفول'))                                            return '🥜';
  if (n.contains('مكسرات'))                                                return '🥜';
  if (n.contains('بذور'))                                                  return '🌰';
  if (n.contains('عباد الشمس'))                                            return '🌻';

  if (n.contains('قهوة') || n.contains('اسبريسو') || n.contains('كابتشينو') || n.contains('لاتيه')) return '☕';
  if (n.contains('ماتشا') || n.contains('شاي أعشاب'))                     return '🍵';
  if (n.contains('شاي'))                                                   return '🍵';
  if (n.contains('شوكولاتة ساخنة'))                                        return '🍫';

  if (n.contains('بروتين شيك'))                                            return '💪';
  if (n.contains('ميلك شيك'))                                              return '🥛';
  if (n.contains('سموذي'))                                                 return '🥤';
  if (n.contains('شيك'))                                                   return '🥤';
  if (n.contains('عصير'))                                                  return '🧃';
  if (n.contains('ليمونادة'))                                              return '🍋';
  if (n.contains('جوز الهند'))                                             return '🥥';
  if (n.contains('صودا'))                                                  return '🥤';
  if (n.contains('مياه') || n.contains('ماء'))                            return '💧';

  if (n.contains('بروتين'))                                                return '💪';
  if (n.contains('نباتي'))                                                 return '🌱';
  if (n.contains('ديتوكس'))                                                return '🌿';
  if (n.contains('مكمل'))                                                  return '💊';
  if (n.contains('دايت'))                                                  return '🥗';

  if (n.contains('chicken'))                                               return '🍗';
  if (n.contains('turkey'))                                                return '🦃';
  if (n.contains('duck'))                                                  return '🦆';

  if (n.contains('kebab') || n.contains('kofta'))                         return '🍖';
  if (n.contains('lamb'))                                                  return '🍖';
  if (n.contains('bacon'))                                                 return '🥓';
  if (n.contains('sausage') || n.contains('hot dog'))                     return '🌭';
  if (n.contains('ribs'))                                                  return '🍖';
  if (n.contains('liver'))                                                 return '🥩';
  if (n.contains('beef') || n.contains('steak'))                          return '🥩';

  if (n.contains('shrimp'))                                                return '🍤';
  if (n.contains('crab'))                                                  return '🦀';
  if (n.contains('lobster'))                                               return '🦞';
  if (n.contains('squid') || n.contains('calamari'))                      return '🦑';
  if (n.contains('oyster'))                                                return '🦪';
  if (n.contains('sushi'))                                                 return '🍣';
  if (n.contains('salmon'))                                                return '🍣';
  if (n.contains('tuna') || n.contains('fish'))                           return '🐟';

  if (n.contains('omelette') || n.contains('omelet') || n.contains('scrambled')) return '🍳';
  if (n.contains('boiled egg'))                                            return '🥚';
  if (n.contains('egg'))                                                   return '🥚';
  if (n.contains('yogurt'))                                                return '🫙';
  if (n.contains('cheese'))                                                return '🧀';
  if (n.contains('butter'))                                                return '🧈';
  if (n.contains('ice cream'))                                             return '🍨';
  if (n.contains('cream'))                                                 return '🍦';
  if (n.contains('milk'))                                                  return '🥛';

  if (n.contains('salad') || n.contains('caesar') || n.contains('coleslaw')) return '🥗';
  if (n.contains('lettuce') || n.contains('spinach'))                     return '🥬';
  if (n.contains('broccoli'))                                              return '🥦';
  if (n.contains('carrot'))                                                return '🥕';
  if (n.contains('corn'))                                                  return '🌽';
  if (n.contains('tomato'))                                                return '🍅';
  if (n.contains('cucumber'))                                              return '🥒';
  if (n.contains('pepper'))                                                return '🫑';
  if (n.contains('mushroom'))                                              return '🍄';
  if (n.contains('onion'))                                                 return '🧅';
  if (n.contains('garlic'))                                                return '🧄';
  if (n.contains('sweet potato'))                                          return '🍠';
  if (n.contains('potato'))                                                return '🥔';
  if (n.contains('avocado'))                                               return '🥑';
  if (n.contains('eggplant'))                                              return '🍆';
  if (n.contains('peas'))                                                  return '🟢';
  if (n.contains('lentil') || n.contains('chickpea'))                     return '🫘';
  if (n.contains('beans'))                                                 return '🫘';

  if (n.contains('soup'))                                                  return '🍲';
  if (n.contains('stew'))                                                  return '🫕';
  if (n.contains('broth'))                                                 return '🍵';

  if (n.contains('fried rice'))                                            return '🍳';
  if (n.contains('rice'))                                                  return '🍚';
  if (n.contains('oat') || n.contains('granola') || n.contains('porridge')) return '🥣';
  if (n.contains('quinoa') || n.contains('freekeh'))                      return '🌾';
  if (n.contains('couscous'))                                              return '🍚';

  if (n.contains('pasta') || n.contains('spaghetti') || n.contains('ravioli') || n.contains('lasagna') || n.contains('penne')) return '🍝';
  if (n.contains('noodle') || n.contains('ramen'))                        return '🍜';

  if (n.contains('croissant'))                                             return '🥐';
  if (n.contains('bagel'))                                                 return '🥯';
  if (n.contains('muffin'))                                                return '🧁';
  if (n.contains('pancake'))                                               return '🥞';
  if (n.contains('waffle'))                                                return '🧇';
  if (n.contains('pita'))                                                  return '🫓';
  if (n.contains('bread') || n.contains('toast'))                         return '🍞';

  if (n.contains('sandwich'))                                              return '🥪';
  if (n.contains('burger'))                                                return '🍔';
  if (n.contains('shawarma'))                                              return '🌯';
  if (n.contains('falafel'))                                               return '🧆';
  if (n.contains('pizza'))                                                 return '🍕';
  if (n.contains('wrap'))                                                  return '🌯';
  if (n.contains('taco'))                                                  return '🌮';
  if (n.contains('burrito'))                                               return '🌯';
  if (n.contains('fries'))                                                 return '🍟';
  if (n.contains('nugget'))                                                return '🍗';
  if (n.contains('nachos'))                                                return '🧀';
  if (n.contains('hot dog'))                                               return '🌭';
  if (n.contains('dumpling'))                                              return '🥟';
  if (n.contains('spring roll'))                                           return '🥢';
  if (n.contains('curry') || n.contains('biryani'))                       return '🍛';
  if (n.contains('hummus'))                                                return '🫘';
  if (n.contains('tahini'))                                                return '🥣';
  if (n.contains('stuffed'))                                               return '🫑';
  if (n.contains('moussaka'))                                              return '🍆';
  if (n.contains('koshari'))                                               return '🍚';
  if (n.contains('molokheya'))                                             return '🥬';

  if (n.contains('cheesecake'))                                            return '🍰';
  if (n.contains('donut'))                                                 return '🍩';
  if (n.contains('brownie'))                                               return '🍫';
  if (n.contains('cookie'))                                                return '🍪';
  if (n.contains('cake'))                                                  return '🎂';
  if (n.contains('chocolate'))                                             return '🍫';
  if (n.contains('pudding'))                                               return '🍮';
  if (n.contains('pie'))                                                   return '🥧';
  if (n.contains('candy'))                                                 return '🍬';
  if (n.contains('honey'))                                                 return '🍯';
  if (n.contains('konafa'))                                                return '🍮';
  if (n.contains('baklava'))                                               return '🍯';
  if (n.contains('rice pudding'))                                          return '🍚';

  if (n.contains('strawberry'))                                            return '🍓';
  if (n.contains('mango'))                                                 return '🥭';
  if (n.contains('watermelon'))                                            return '🍉';
  if (n.contains('pineapple'))                                             return '🍍';
  if (n.contains('orange'))                                                return '🍊';
  if (n.contains('banana'))                                                return '🍌';
  if (n.contains('apple'))                                                 return '🍎';
  if (n.contains('grape'))                                                 return '🍇';
  if (n.contains('peach'))                                                 return '🍑';
  if (n.contains('pear'))                                                  return '🍐';
  if (n.contains('cherry'))                                                return '🍒';
  if (n.contains('lemon'))                                                 return '🍋';
  if (n.contains('dates'))                                                 return '🌴';
  if (n.contains('fig'))                                                   return '🍈';
  if (n.contains('coconut'))                                               return '🥥';
  if (n.contains('fruit'))                                                 return '🍎';

  if (n.contains('peanut butter'))                                         return '🥜';
  if (n.contains('almond') || n.contains('walnut') || n.contains('peanut')) return '🥜';
  if (n.contains('nut'))                                                   return '🥜';
  if (n.contains('seed'))                                                  return '🌰';
  if (n.contains('sunflower'))                                             return '🌻';

  if (n.contains('espresso') || n.contains('cappuccino') || n.contains('coffee')) return '☕';
  if (n.contains('latte'))                                                 return '🥛';
  if (n.contains('matcha') || n.contains('herbal') || n.contains('tea')) return '🍵';
  if (n.contains('hot chocolate'))                                         return '🍫';

  if (n.contains('protein shake'))                                         return '💪';
  if (n.contains('milk shake'))                                            return '🥛';
  if (n.contains('smoothie'))                                              return '🥤';
  if (n.contains('shake'))                                                 return '🥤';
  if (n.contains('juice'))                                                 return '🧃';
  if (n.contains('lemonade'))                                              return '🍋';
  if (n.contains('soda'))                                                  return '🥤';
  if (n.contains('water'))                                                 return '💧';

  if (n.contains('protein'))                                               return '💪';
  if (n.contains('vegan'))                                                 return '🌱';
  if (n.contains('detox'))                                                 return '🌿';
  if (n.contains('supplement'))                                            return '💊';
  if (n.contains('diet'))                                                  return '🥗';

  return '🍽️';
}

String guessFoodCategory(String name) {
  final n = name.toLowerCase();

  if (n.contains('oat') ||
      n.contains('شوفان') ||
      n.contains('فطار') ||
      n.contains('فطور') ||
      n.contains('egg') ||
      n.contains('بيض') ||
      n.contains('omelette') ||
      n.contains('عجة') ||
      n.contains('toast') ||
      n.contains('توست') ||
      n.contains('pancake') ||
      n.contains('بان كيك') ||
      n.contains('waffle') ||
      n.contains('وافل') ||
      n.contains('yogurt') ||
      n.contains('زبادي') || n.contains('زبادى') ||
      n.contains('smoothie') ||
      n.contains('سموذي') ||
      n.contains('granola') ||
      n.contains('cereal') ||
      n.contains('فول مدمس') ||
      n.contains('فول') ||
      n.contains('عيش بالبيض') ||
      n.contains('كرواسون') ||
      n.contains('croissant') ||
      n.contains('bagel') ||
      n.contains('رغيف') ||
      n.contains('خبز') ||
      n.contains('عيش'))
    return 'breakfast';

  if (n.contains('steak') ||
      n.contains('grilled') ||
      n.contains('مشوي') ||
      n.contains('roast') ||
      n.contains('محمر') ||
      n.contains('pasta') ||
      n.contains('مكرونة') ||
      n.contains('باستا') ||
      n.contains('pizza') ||
      n.contains('بيتزا') ||
      n.contains('burger') ||
      n.contains('برجر') ||
      n.contains('ravioli') ||
      n.contains('lasagna') ||
      n.contains('كباب') ||
      n.contains('kebab') ||
      n.contains('كفتة') ||
      n.contains('kofta') ||
      n.contains('شاورما') ||
      n.contains('shawarma') ||
      n.contains('محشي') ||
      n.contains('محشو') ||
      n.contains('stuffed') ||
      n.contains('مسقعة') ||
      n.contains('moussaka') ||
      n.contains('أرز باللحم') ||
      n.contains('فراخ محمرة') ||
      n.contains('سمك مشوي') ||
      n.contains('salmon') ||
      n.contains('ملوخية') ||
      n.contains('molokheya') ||
      n.contains('يخنة') ||
      n.contains('stew'))
    return 'dinner';

  if (n.contains('bar') ||
      n.contains('nut') ||
      n.contains('مكسرات') ||
      n.contains('chocolate') ||
      n.contains('شوكولاتة') ||
      n.contains('cookie') ||
      n.contains('كوكيز') ||
      n.contains('chip') ||
      n.contains('شيبس') ||
      n.contains('popcorn') ||
      n.contains('فشار') ||
      n.contains('cracker') ||
      n.contains('كراكر') ||
      n.contains('candy') ||
      n.contains('حلوى') ||
      n.contains('fruit') ||
      n.contains('فاكهة') ||
      n.contains('juice') ||
      n.contains('عصير') ||
      n.contains('protein shake') ||
      n.contains('بروتين شيك') ||
      n.contains('energy') ||
      n.contains('طاقة'))
    return 'snacks';

  if (n.contains('كشري') ||
      n.contains('koshari') ||
      n.contains('فلافل') ||
      n.contains('falafel') ||
      n.contains('حمص') || n.contains('حمص مشوى') || n.contains('حمص مشوي') ||
      n.contains('hummus') ||
      n.contains('سلطة') ||
      n.contains('salad') ||
      n.contains('شوربة') || n.contains('كزبرة') ||
      n.contains('soup') ||
      n.contains('ساندويتش') ||
      n.contains('ساندوتش') ||
      n.contains('sandwich') ||
      n.contains('wrap') ||
      n.contains('راب') ||
      n.contains('أرز') ||
      n.contains('rice') ||
      n.contains('عدس') ||
      n.contains('lentil'))
    return 'lunch';

  return 'lunch';
}