/// Mescla dois vetores já ordenados mantendo a ordem
pub fn mesclar_ordenados(mut a: Vec<i32>, mut b: Vec<i32>) -> Vec<i32> {
    let mut res = Vec::with_capacity(a.len() + b.len());

    while !a.is_empty() && !b.is_empty() {
        if a[0] <= b[0] {
            res.push(a.remove(0));
        } else {
            res.push(b.remove(0));
        }
    }

    res.extend(a);
    res.extend(b);

    res
}

fn main() {
    let v1 = vec![1, 3, 5, 7, 9];
    let v2 = vec![2, 4, 6, 8, 10];

    let resultado = mesclar_ordenados(v1, v2);

    println!("Vetores mesclados:");
    println!("{:?}", resultado);
}