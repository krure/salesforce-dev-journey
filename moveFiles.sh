# Mueve todo, incluidos los archivos ocultos, excepto los que chocan con la raíz
cd Project/Portfolio
for f in $(ls -A); do
  git mv "$f" ../../ 2>&1 | grep -v "^$" || true
done
cd ../..