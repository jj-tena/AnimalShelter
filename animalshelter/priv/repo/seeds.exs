alias Animalshelter.Repo
alias Animalshelter.Animals.Animal

%Animal{
  name: "Luna",
  description: "Gatita blanca muy cariñosa, rescatada de la calle. Le encanta dormir al sol y jugar con pelotas.",
  specie: "Gato",
  breed: "Angora turco",
  age: 2,
  status: :open,
  image_path: "/images/cat-luna.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()

%Animal{
  name: "Max",
  description: "Perro mestizo muy enérgico, ideal para familias activas. Se lleva bien con otros perros.",
  specie: "Perro",
  breed: "Mestizo",
  age: 3,
  status: :open,
  image_path: "/images/dog-max.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()

%Animal{
  name: "Nala",
  description: "Perra pastor alemán rescatada, muy protectora y obediente. Perfecta para compañía y guardia.",
  specie: "Perro",
  breed: "Pastor alemán",
  age: 4,
  status: :upcoming,
  image_path: "/images/dog-nala.jpg",
  disease: "Displasia de cadera"
}
|> Repo.insert!()

%Animal{
  name: "Milo",
  description: "Conejito pequeño de orejas caídas, muy tranquilo y amigable con niños.",
  specie: "Conejo",
  breed: "Belier enano",
  age: 1,
  status: :open,
  image_path: "/images/rabbit-milo.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()

%Animal{
  name: "Kira",
  description: "Gata tricolor muy lista, le encanta trepar y explorar. Esterilizada y vacunada.",
  specie: "Gato",
  breed: "Calicó",
  age: 3,
  status: :open,
  image_path: "/images/cat-kira.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()

%Animal{
  name: "Rocky",
  description: "Pitbull fuerte pero muy tierno. Ha pasado por rehabilitación y busca un hogar paciente.",
  specie: "Perro",
  breed: "Pitbull",
  age: 5,
  status: :upcoming,
  image_path: "/images/dog-rocky.jpg",
  disease: "Alergias en la piel"
}
|> Repo.insert!()

%Animal{
  name: "Chispa",
  description: "Hurón juguetón que fue abandonado. Le encanta correr por tubos y esconder juguetes.",
  specie: "Hurón",
  breed: "Estándar",
  age: 2,
  status: :open,
  image_path: "/images/ferret-chispa.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()

%Animal{
  name: "Toby",
  description: "Golden Retriever muy sociable, se lleva bien con niños, gatos y otros perros.",
  specie: "Perro",
  breed: "Golden Retriever",
  age: 4,
  status: :open,
  image_path: "/images/dog-toby.jpg",
  disease: "Infección de oído (en tratamiento)"
}
|> Repo.insert!()

%Animal{
  name: "Cleo",
  description: "Gata adulta tranquila y muy independiente. Ideal para casas sin otros animales.",
  specie: "Gato",
  breed: "Siamés",
  age: 6,
  status: :close,
  image_path: "/images/cat-cleo.jpg",
  disease: "Insuficiencia renal crónica"
}
|> Repo.insert!()

%Animal{
  name: "Thor",
  description: "Pastor belga muy activo, ideal para entrenamiento y agilidad. Requiere espacio amplio.",
  specie: "Perro",
  breed: "Pastor belga malinois",
  age: 2,
  status: :upcoming,
  image_path: "/images/dog-thor.jpg",
  disease: "Ninguna"
}
|> Repo.insert!()
