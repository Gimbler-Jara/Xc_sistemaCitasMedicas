//
//  HomeViewController.swift
//  SistemaCitasMedicas
//
//  Created by Emerson Jara Gamarra on 17/08/25.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var items: [EspecialidadLocal] = []
    private let ctx = CoreDataStack.shared.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EspecialidadSeeder.seedIfNeeded()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchEspecialidades()
    }
    
    
    
    @IBAction func btnLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "login", sender: self)
    }
    
    
    
    
    private func fetchEspecialidades() {
        let req = NSFetchRequest<EspecialidadLocal>(entityName: "EspecialidadLocal")
        req.sortDescriptors = [NSSortDescriptor(key: "orden", ascending: true)]
        do {
            items = try ctx.fetch(req)
            collectionView.reloadData()
        } catch {
            print("Fetch especialidades error:", error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EspecialidadCell", for: indexPath) as? EspecialidadCell
        else { return UICollectionViewCell() }
        
        let e = items[indexPath.item]
        cell.titleLbl.text = e.nombre
        if let name = e.assetName, !name.isEmpty {
            cell.imageView.image = UIImage(named: name) ?? UIImage(systemName: "photo")
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = view.bounds.width > 600 ? 3 : 2
        let spacing: CGFloat = 12
        let sectionInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        let totalSpacing = sectionInsets.left + sectionInsets.right + (spacing * (columns - 1))
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        
        return CGSize(width: width, height: width + 24)
    }
    
}
